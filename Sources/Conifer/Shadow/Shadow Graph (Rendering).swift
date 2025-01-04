// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

extension ShadowGraph {
	
	/// Renders if needed the component at a given location in `self` and returns the rendered component.
	///
	/// If the component is known to be rendered, use `prerenderedComponent(at:)` instead.
	///
	/// - Requires: `location` refers to a (possibly not-yet-rendered) component whose parent is already rendered.
	func renderIfNeededComponent(at location: ShadowLocation) async throws -> any Component {
		
		if let component = componentIfRendered(at: location) {
			return component
		}
		
		try await renderIfNeededChildren(ofComponentAt: location.parent !! "Expected parent of component at \(location) to be already rendered")
		return prerenderedComponent(at: location)
		
	}
	
	/// Returns an already rendered component in the shadow graph at a given location relative to the root component.
	///
	/// If the component is not known to be rendered, use `renderIfNeededComponent(at:)` instead.
	///
	/// - Requires: `location` refers to an already rendered component in `self`.
	func prerenderedComponent(at location: ShadowLocation) -> any Component {
		componentIfRendered(at: location) !! "Expected component at \(location) to be already rendered"
	}
	
	/// Returns the component at a given location, or `nil` if it has not been rendered yet.
	fileprivate func componentIfRendered(at location: ShadowLocation) -> (any Component)? {
		element(ofType: (any Component).self, at: location)
	}
	
	/// Assigns or replaces the component at a given location in the graph.
	fileprivate func update(_ component: any Component, at location: ShadowLocation) {
		update(component, ofType: (any Component).self, at: location)
	}
	
	/// Renders if needed the children of the component at `parentLocation` and returns their locations.
	///
	/// - Requires: `parentLocation` refers to a rendered component in `self`.
	/// - Postcondition: `element(ofType: ShadowChildLocations.self, at: parentLocation)` is equal to this method's result.
	/// - Postcondition: Each `location` in the returned array refers to a rendered component in `self`.
	///
	/// - Parameter parentLocation: The location of the component whose children to render if necessary.
	///
	/// - Returns: The locations of the children of the component at `parentLocation`.
	@discardableResult
	func renderIfNeededChildren(ofComponentAt parentLocation: ShadowLocation) async throws -> ShadowChildLocations {
		
		if let childLocations = element(ofType: ShadowChildLocations.self, at: parentLocation) {
			return childLocations
		}
		
		let parent = prerenderedComponent(at: parentLocation)
		return try await renderChildren(of: parent, under: parentLocation)
		
	}
	
	/// Renders the children of `parent` under given location in `self` and returns the locations of those children.
	///
	/// This method supports both foundational and non-foundational `parent`s.
	///
	/// - Requires: The properties on `parent` are prepared.
	/// - Postcondition: `element(ofType: ShadowChildLocations.self, at: parentLocation)` is equal to this method's result.
	///
	/// - Parameter parent: The component whose children to render.
	/// - Parameter parentLocation: The location of `parent` in `self`.
	///
	/// - Returns: The locations of the rendered children.
	fileprivate func renderChildren(of parent: some Component, under parentLocation: ShadowLocation) async throws -> ShadowChildLocations {
		
		// Special-case foundational components.
		if let component = self as? any FoundationalComponent {
			return try await renderChildren(of: component, under: parentLocation)
		}
		
		// Render body.
		let childLocation = parentLocation[.body]
		try await render(parent.body, at: childLocation)
		
		// Update child locations on graph.
		let childLocations = ShadowChildLocations([childLocation])
		update(childLocations, at: parentLocation)
		
		return childLocations
		
	}
	
	/// Renders the children of `parent` under given location in `self` and returns the locations of those children.
	///
	/// This method overloads `renderChildren(of:under:)` for foundational `parent`s.
	///
	/// - Requires: The properties on `parent` are prepared.
	/// - Postcondition: `element(ofType: ShadowChildLocations.self, at: parentLocation)` is equal to this method's result.
	///
	/// - Parameter parent: The component whose children to render.
	/// - Parameter parentLocation: The location of `parent` in `self`.
	///
	/// - Returns: The locations of the rendered children.
	fileprivate func renderChildren(of parent: some FoundationalComponent, under parentLocation: ShadowLocation) async throws -> ShadowChildLocations {
		
		// Determine child locations.
		let shadow = parent.makeShadow(graph: self, location: parentLocation)
		let relativeChildLocations = try await parent.childLocations(for: shadow)
		let absoluteChildLocations = relativeChildLocations.map { parentLocation[$0] }
		
		// Render children.
		for (relativeChildLocation, absoluteChildLocation) in zip(relativeChildLocations, absoluteChildLocations) {
			let child = try await parent.child(at: relativeChildLocation, for: shadow)
			try await render(child, at: absoluteChildLocation)
		}
		
		// Update child locations on graph.
		let childLocations = ShadowChildLocations(absoluteChildLocations)
		update(childLocations, at: parentLocation)
		
		// Finalise.
		try await parent.finalise(shadow)	// may trigger additional renderings
		
		return childLocations
		
	}
	
	/// Prepares a given component's dynamic properties and adds it at a given location to the shadow graph.
	func render(_ component: some Component, at location: ShadowLocation) async throws {
		var component = component
		try await component.updateDynamicProperties(for: component.makeShadow(graph: self, location: location))
		update(component, at: location)
	}
	
}
