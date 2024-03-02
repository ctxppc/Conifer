// Conifer © 2019–2024 Constantino Tsarouhas

/// A component updating the context of its content.
public struct Contextualised<Content : Component, Value> : @unchecked Sendable, Component {
	
	/// Creates a component where the contextualised value for `key` for `content` is set to `value`.
	fileprivate init(key: Context.Key<Value>, value: Value, @ComponentBuilder content: @escaping ContentProvider) {
		self.key = key
		self.value = value
		self.content = content
	}
	
	/// The context key path for which `self` provides a value.
	public let key: Context.Key<Value>
	
	/// The contextual value.
	public let value: Value
	
	/// The contextualised content.
	public let content: ContentProvider
	public typealias ContentProvider = @Sendable () -> Content
	
	// See protocol.
	public var body: some Component {
		content()
	}
	
}

extension Component {
	
	/// Returns a component where the contextualised value for `key` for `content` is set to `value`.
	public func context<Value>(_ key: Context.Key<Value>, _ value: Value) -> Contextualised<Self, Value> {
		.init(key: key, value: value) {
			self
		}
	}
	
}

protocol ContextualisedProtocol {
	
	/// Updates given context.
	func update(_ context: inout Context)
	
}

extension Contextualised : ContextualisedProtocol {
	func update(_ context: inout Context) {
		context[key] = value
	}
}
