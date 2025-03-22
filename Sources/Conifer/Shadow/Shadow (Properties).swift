// Conifer © 2019–2025 Constantino Tsarouhas

extension Shadow {
	
	/// Accesses a stored shadow property at a given key path on `self`.
	///
	/// If a component is being rendered, this method records a dependency of that component on the shadow property on `self`. That component is invalidated whenever the shadow property changes.
	public subscript <Value : Sendable>(dynamicMember keyPath: WritableKeyPath<ShadowSnapshot, Value> & Sendable) -> Value {
		get async {
			await { (graph: isolated ShadowGraph) in
				graph.recordRead(from: location, property: keyPath)
				return graph[location]![keyPath: keyPath]
			}(graph)
		}
	}
	
	/// Assigns or reassigns a value to a stored shadow property at a given key path on `self`.
	///
	/// This method invalidates all components that depend on the shadow property.
	public func set<Value : Sendable>(_ keyPath: WritableKeyPath<ShadowSnapshot, Value> & Sendable, _ newValue: Value) async {
		await { (graph: isolated ShadowGraph) in
			graph.recordWrite(to: location, property: keyPath)
			graph[location]![keyPath: keyPath] = newValue
		}(graph)
	}
	
	/// Updates a value to a stored shadow property at a given key path on `self`.
	///
	/// This method invalidates all components that depend on the shadow property.
	public func update<Value : Sendable>(_ keyPath: WritableKeyPath<ShadowSnapshot, Value> & Sendable, with transform: sending (Value) -> Value) async {
		await { (graph: isolated ShadowGraph) in
			graph.recordRead(from: location, property: keyPath)
			graph.recordWrite(to: location, property: keyPath)
			graph[location]![keyPath: keyPath] = transform(graph[location]![keyPath: keyPath])
		}(graph)
	}
	
	/// Returns the value of a shadow property, computing it first if necessary.
	///
	/// If the shadow property at `keyPath` is `nil`, this method performs `compute` to determine a value, sets the property at `keyPath` to this value, and returns the value. Every shadow property that `compute` accesses is recorded as a dependency for `keyPath`. Conifer sets `keyPath` to `nil`, thereby invalidating it, whenever any dependency changes.
	///
	/// If the shadow property at `keyPath` is not `nil`, this method simply returns it.
	///
	/// - Parameters:
	///    - keyPath: A key path from a shadow snapshot to a shadow property.
	///    - compute: A function that computes the value of the shadow property.
	///
	/// - Throws: `DependencyError.cyclicDependency` if Conifer detects a cyclic dependency, or any error thrown by `compute`.
	public func cached<Value : Sendable>(
		_ keyPath:	WritableKeyPath<ShadowSnapshot, Value?> & Sendable,
		compute:	sending () async throws -> Value
	) async throws -> Value {
		try await { (graph: isolated ShadowGraph) in
			if let value = graph[location]![keyPath: keyPath] {
				return value
			} else {
				// TODO: Track dependencies
				let value = try await compute()
				graph[location]![keyPath: keyPath] = value
				return value
			}
		}(graph)
	}
	
}
