// Conifer © 2019–2024 Constantino Tsarouhas

extension ShadowGraph {
	
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
		
		if let childLocations = self[ofType: ShadowChildLocations.self, parentLocation] {
			return childLocations
		}
		
		let parent = self[prerendered: parentLocation]
		let childLocations: ShadowChildLocations
		if let parent = parent as? any FoundationalComponent {
			
			let labelledChildren = try await parent.labelledChildren(for: self).map { location, child in
				(parentLocation[location], child)
			}
			
			for (childLocation, child) in labelledChildren {
				try await render(child: child, at: childLocation)
			}
			
			childLocations = .init(labelledChildren.map { $0.0 })
			
		} else {
			let childLocation = parentLocation[.body]
			try await render(child: parent.body, at: childLocation)
			childLocations = .init([childLocation])
		}
		
		self[parentLocation] = childLocations
		return childLocations
		
	}
	
	/// Prepares a given child's dynamic properties and adds it at a given location to the shadow graph.
	func render(child: some Component, at location: Location) async throws {
		var child = child
		try await child.prepareForRendering(shadow: .init(graph: self, location: location))
		componentsByLocation.updateValue(child, forKey: location)
	}
	
}

extension Component {
	
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
	private mutating func prepareProperty(at keyPath: PartialKeyPath<Self>, forRendering shadow: UntypedShadow) async throws {
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
