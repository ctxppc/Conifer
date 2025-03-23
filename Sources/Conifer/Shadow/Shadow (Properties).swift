// Conifer © 2019–2025 Constantino Tsarouhas

extension Shadow {
	
	/// Accesses a stored shadow value of a given property on `self`.
	///
	/// If a component is being rendered, this method records a dependency of that component on the shadow property on `self`. That component is invalidated whenever the shadow property changes.
	public subscript <Value : Sendable>(dynamicMember property: ShadowSnapshot.Property<Value>) -> Value {
		get async {
			await { (graph: isolated ShadowGraph) in
				recordRead(from: property, graph: graph)
				return graph[location]![keyPath: property]
			}(graph)
		}
	}
	
	/// Assigns or reassigns a stored shadow value of a given property on `self`.
	///
	/// This method invalidates all components that depend on the shadow property.
	///
	/// - Throws: `DependencyError.cycle` if a cyclic dependency is detected.
	public func set<Value : Sendable>(_ property: ShadowSnapshot.Property<Value>, _ newValue: Value) async throws(DependencyError) {
		try await { (graph: isolated ShadowGraph) throws(DependencyError) in
			try recordWrite(to: property, graph: graph)
			graph[location]![keyPath: property] = newValue
		}(graph)
	}
	
	/// Updates a stored shadow value of a given property on `self`.
	///
	/// This method invalidates all components that depend on the shadow property.
	///
	/// - Throws: `DependencyError.cycle` if a cyclic dependency is detected.
	public func update<Value : Sendable>(_ property: ShadowSnapshot.Property<Value>, with transform: sending (Value) -> Value) async throws(DependencyError) {
		try await { (graph: isolated ShadowGraph) throws(DependencyError) in
			recordRead(from: property, graph: graph)
			try recordWrite(to: property, graph: graph)
			graph[location]![keyPath: property] = transform(graph[location]![keyPath: property])
		}(graph)
	}
	
	/// Returns the shadow value backed by a given stored shadow property, computing it using a given function if necessary.
	///
	/// If the stored shadow value is `nil`, this method performs `compute` to determine its new value, sets the stored shadow property to this value, and returns the value. Every shadow property that `compute` accesses is recorded as a dependency for `keyPath`. Conifer sets `keyPath` to `nil`, thereby invalidating it, whenever any dependency changes.
	///
	/// If the stored shadow value is not `nil`, this method simply returns it.
	///
	/// - Parameters:
	///    - storedProperty: The shadow property storing the cached value (or `nil` if invalid).
	///    - compute: A function that computes the shadow value (when the stored shadow value is invalid).
	///
	/// - Throws: `DependencyError.cycle` if a cyclic dependency is detected; or any error thrown by `compute`.
	public func cached<Value : Sendable>(
		in storedProperty:	ShadowSnapshot.Property<Value?>,
		compute:			sending () async throws -> Value
	) async throws -> Value {
		try await { (graph: isolated ShadowGraph) in
			if let value = graph[location]![keyPath: storedProperty] {
				return value
			} else {
				let value = try await recordDependencies(of: storedProperty, graph: graph, compute: compute)
				graph[location]![keyPath: storedProperty] = value
				return value
			}
		}(graph)
	}
	
}
