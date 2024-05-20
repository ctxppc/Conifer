// Conifer © 2019–2024 Constantino Tsarouhas

extension Component {
	
	/// Sets the contextual value for `key` to `value`.
	public func context<Value>(_ key: Context.Key<Value>, _ value: Value) -> Modified<Self, some Modifier> {
		modifier(ContextModifier(key: key, value: value))
	}
	
}

private struct ContextModifier<Value : Sendable> : Modifier, @unchecked Sendable {	// Context.Key is immutable
	
	/// The contextual key that is set.
	let key: Context.Key<Value>
	
	/// The contextual value.
	let value: Value
	
	// See protocol.
	func update(_ shadow: some Shadow) async throws {
		var context = try await shadow.parent?.context ?? .init()
		context[keyPath: key] = value
		await shadow.update(context)
	}
	
}
