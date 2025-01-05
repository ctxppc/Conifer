// Conifer © 2019–2025 Constantino Tsarouhas

extension ShadowGraph {
	
	/// Records a dependency of a component being rendered on an element in the graph.
	///
	/// This method does nothing if no component is being rendered. A shadow graph only records internal dependencies.
	func recordRead<E>(at accessedLocation: Location, elementType: E.Type) {
		guard let dependentLocation = renderingLocation else { return }
		update([Dependency].self, with: { dependencies in
			(dependencies ?? []).appending(.init(elementType: elementType, dependentLocation: dependentLocation))
		}, at: accessedLocation)
	}
	
	/// Invalidates components that depend on an element in the graph.
	func recordWrite<E>(at accessedLocation: Location, elementType: E.Type) {
		guard let dependencies = element(ofType: [Dependency].self, at: accessedLocation) else { return }
		for dependency in dependencies where dependency.elementType == elementType {
			invalidateComponent(at: dependency.dependentLocation)
		}
	}
	
	/// An element on a shadow of a dependable component specifying a dependency of a dependent shadow on the dependable component.
	private struct Dependency : Sendable {
		
		/// The element type of the dependent element.
		var elementType: Any.Type
		
		/// The location of the shadow that depends on an element of type `elementType`.
		var dependentLocation: Location
		
	}
	
}
