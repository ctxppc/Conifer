// Conifer © 2019–2024 Constantino Tsarouhas

public struct Contextualised<Content : Component, Value> : @unchecked Sendable, FoundationalComponent {
	
	/// Creates a component where the contextualised value for `key` for `content` is set to `value`.
	fileprivate init(content: Content, key: Context.Key<Value>, value: Value) {
		self.content = content
		self.key = key
		self.value = value
	}
	
	/// The contextualised content.
	public let content: Content
	
	/// The context key path for which `self` provides a value.
	public let key: Context.Key<Value>
	
	/// The contextual value.
	public let value: Value
	
	// See protocol.
	public var body: Never {
		hasNoBody
	}
	
	// See protocol.
	func labelledChildren(for graph: ShadowGraph) async throws -> [(Location, any Component)] {
		[(.child(at: 0), content)]	// TODO: Context?
	}
	
}

extension Component {
	
	/// Returns a component where the contextualised value for `key` for `content` is set to `value`.
	public func context<Value>(_ key: Context.Key<Value>, _ value: Value) -> Contextualised<Self, Value> {
		.init(content: self, key: key, value: value)
	}
	
}
