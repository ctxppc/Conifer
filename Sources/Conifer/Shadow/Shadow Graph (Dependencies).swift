// Conifer © 2019–2025 Constantino Tsarouhas

extension ShadowGraph {
	
	/// Records a dependency on a shadow property.
	///
	/// This method does nothing if no component is being rendered. A shadow graph only records internal dependencies.
	///
	/// - Requires: `accessedLocation` refers to a rendered component.
	@available(*, deprecated)
	func recordRead(from accessedLocation: Location, property: ShadowSnapshot.Property) {
		guard let dependentLocation = renderingLocation else { return }
		guard var s = self[accessedLocation] else {	// FIXME: Components may record reads *while* being rendered!!
			preconditionFailure("\(accessedLocation) does not refer to a rendered component")
		}
		s.dependencies.append(.init(dependentLocation: dependentLocation, dependentProperty: property))
		self[accessedLocation] = s
	}
	
	/// Invalidates components that depend on a shadow property.
	@available(*, deprecated)
	func recordWrite(to accessedLocation: Location, property: ShadowSnapshot.Property) {
		guard let dependencies = self[accessedLocation]?.dependencies else { return }
		for dependency in dependencies where dependency.dependentProperty == property {
			invalidateComponent(at: dependency.dependentLocation)
		}
	}
	
	/// An element on a shadow of a dependable component specifying a dependency of a dependent shadow on the dependable component.
	@available(*, deprecated)
	fileprivate struct Dependency : Sendable {
		
		/// The location of the dependent shadow.
		var dependentLocation: Location
		
		/// A key path to the dependent shadow property.
		var dependentProperty: ShadowSnapshot.Property
		
	}
	
}

fileprivate extension ShadowSnapshot {
	
	/// The dependencies that other components have on `self`.
	@available(*, deprecated)
	var dependencies: [ShadowGraph.Dependency] {
		get { self[\.dependencies] ?? [] }
		set { self[\.dependencies] = newValue }
	}
	
}
