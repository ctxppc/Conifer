// Conifer © 2019–2024 Constantino Tsarouhas

/// A value that can read and update a value owned by a source of truth.
///
/// A binding, like any property on a component, has a fixed value during a rendering cycle. Updates may only be visible in future rendering cycles.
@propertyWrapper
public struct Binding<Value : Sendable> : MutableDynamicProperty {
	
	/// Creates a binding with given getter and sender.
	///
	/// - Parameters:
	///    - get: A function that retrieves the value from the source of truth.
	///    - send: A function that sends a value to the source of truth, requesting it be updated.
	public init(get: @escaping Accessor, send: @escaping Sender) {
		self.get = get
		self._send = send
	}
	
	/// Creates a binding that always returns given value and ignores any attempts at updating it.
	public static func constant(_ value: Value) -> Self {
		.init(get: { value }, send: { _ in })
	}
	
	/// The value owned by the source of truth.
	public var wrappedValue: Value {
		self.get()
	}
	
	// See protocol.
	public func send(updatedValue: Value) {
		_send(updatedValue)
	}
	
	/// A function that retrieves a value from the source of truth.
	private let get: Accessor
	public typealias Accessor = @Sendable () -> Value
	
	/// A function that sends a value to the source of truth, requesting it be updated.
	private let _send: Sender
	public typealias Sender = @Sendable (Value) -> ()
	
	// See protocol.
	public var projectedValue: Self {
		self
	}
	
	// See protocol.
	public mutating func update<Component>(for shadow: some Shadow<Component>, keyPath: any Self.KeyPath<Component>) async throws {
		// Bindings do not have external dependencies.
	}
	
}
