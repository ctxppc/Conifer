// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit

extension ShadowGraph {
	
	/// Accesses a component in the shadow graph at a given location relative to the root component, rendering it if needed.
	///
	/// - Requires: `location` refers to a (possibly not-yet-rendered) component whose parent is already rendered.
	subscript (location: Location) -> any Component {
		get async throws {
			
			if let component = componentIfRendered(at: location) {
				return component
			}
			
			try await renderChildren(ofComponentAt: location.parent !! "Expected root component to be already rendered")
			return self[prerendered: location]
			
		}
	}
	
	/// Accesses an already rendered component in the shadow graph at a given location relative to the root component.
	///
	/// - Requires: `location` refers to an already rendered component in `self`.
	subscript (prerendered location: Location) -> any Component {
		componentIfRendered(at: location) !! "Expected component at \(location) to be already rendered"
	}
	
	/// Returns the component at a given location, or `nil` if it has not been rendered yet.
	func componentIfRendered(at location: Location) -> (any Component)? {
		element(ofType: (any Component).self, at: location)
	}
	
	/// Assigns or replaces the component at a given location in the graph.
	func update(component: any Component, at location: Location) {
		update(component, ofType: (any Component).self, at: location)
	}
	
	/// Renders if needed the children of the component at `parentLocation`.
	///
	/// - Requires: `parentLocation` refers to an already rendered component in `self`.
	/// - Postcondition: `childLocationsByLocation[parentLocation]` is not `nil`.
	/// - Postcondition: For each `location` in `childLocationsByLocation[parentLocation]`, `componentsByLocation[location]` is not `nil`.
	func renderChildren(ofComponentAt parentLocation: Location) async throws {
		_ = try await childLocations(ofComponentAt: parentLocation)
	}
	
	/// Returns the locations of the children of the component at `parentLocation`, rendering them if needed.
	///
	/// - Requires: `parentLocation` refers to an already rendered component in `self`.
	/// - Postcondition: `childLocationsByLocation[parentLocation]` is equal to this method's result.
	/// - Postcondition: For each `location` in the returned array, `componentsByLocation[location]` is not `nil`.
	func childLocations(ofComponentAt parentLocation: Location) async throws -> ShadowChildLocations {
		
		if let childLocations = element(ofType: ShadowChildLocations.self, at: parentLocation) {
			return childLocations
		}
		
		let parent = self[prerendered: parentLocation]
		let childLocations: ShadowChildLocations
		if let parent = parent as? any FoundationalComponent {
			
			// Create child components & rebase locations.
			let labelledChildren = try await parent.labelledChildren(for: self).map { location, child in
				(parentLocation[location], child)
			}
			
			// Render children.
			for (childLocation, child) in labelledChildren {
				try await render(child: child, at: childLocation)
			}
			
			// Update child locations.
			childLocations = .init(labelledChildren.map { $0.0 })
			update(childLocations, at: parentLocation)
			
			// Finalise.
			try await parent.finalise(in: self, at: parentLocation)	// may trigger additional renderings
			
		} else {
			
			// Render non-foundational component.
			let childLocation = parentLocation[.body]
			try await render(child: parent.body, at: childLocation)
			
			// Update child locations.
			childLocations = .init([childLocation])
			update(childLocations, at: parentLocation)
			
		}
		
		return childLocations
		
	}
	
	/// Prepares a given child's dynamic properties and adds it at a given location to the shadow graph.
	func render(child: some Component, at location: Location) async throws {
		var child = child
		try await child.prepareForRendering(shadow: .init(graph: self, location: location))
		update(component: child, at: location)
	}
	
}

private extension Component {
	
	/// Prepares `self` for rendering.
	///
	/// This method prepares the dynamic properties declared on `self`.
	///
	/// - Parameter shadow: The shadow of `self`.
	mutating func prepareForRendering(shadow: UntypedShadow) async throws {
		for keyPath in PartialKeyPath<Self>.allKeyPaths() {
			try await prepareProperty(at: keyPath, forRendering: shadow)
		}
	}
	
	/// Prepares the property at `keyPath` on `self` for rendering.
	///
	/// This method does nothing if the property at `keyPath` is not a stored property whose type conforms to `DynamicProperty`.
	///
	/// - Parameter keyPath: The key path from `self` to the property to prepare.
	/// - Parameter shadow: A shadow of `self`.
	mutating func prepareProperty(at keyPath: PartialKeyPath<Self>, forRendering shadow: UntypedShadow) async throws {
		guard let keyPath = keyPath as? any DynamicPropertyKeyPath<Self> else { return }
		try await keyPath.prepareDynamicProperty(on: &self, forRendering: shadow)
	}
	
}

/// A key path from a component to a (stored) dynamic property.
private protocol DynamicPropertyKeyPath<Root> {
	
	/// A value on which `self` can be applied to.
	associatedtype Root : Component
	
	/// A value that `self` evaluates to when applied.
	associatedtype Value : DynamicProperty
	
	/// Prepares the dynamic property `component[keyPath: self]` for rendering `shadow`.
	func prepareDynamicProperty(on component: inout Root, forRendering shadow: UntypedShadow) async throws
	
}

extension WritableKeyPath : DynamicPropertyKeyPath where Root : Component, Value : DynamicProperty {
	func prepareDynamicProperty(on component: inout Root, forRendering shadow: UntypedShadow) async throws {
		try await component[keyPath: self].update(for: shadow, propertyIdentifier: "\(self)")
	}
}

private extension FoundationalComponent {
	func finalise(in graph: ShadowGraph, at location: Location) async throws {
		try await finalise(Shadow<Self>(graph: graph, location: location))
	}
}
