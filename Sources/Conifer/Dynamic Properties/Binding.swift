// Conifer © 2019–2024 Constantino Tsarouhas

/// A value that can read and write a value owned by a source of truth.
@propertyWrapper
public struct Binding<Value> : Sendable {
	
	/// Creates a binding with given getter and setter.
	public init(get: @escaping Accessor, set: @escaping Mutator) {
		self.get = get
		self.set = set
	}
	
	/// Creates a binding that always returns given value.
	public static func constant(_ value: Value) -> Self {
		.init(get: { value }, set: { _ in })
	}
	
	/// The value owned by the source of truth.
	public var wrappedValue: Value {
		get { get() }
		set { set(newValue) }
	}
	
	/// A function that retrieves a value.
	private let get: Accessor
	public typealias Accessor = @Sendable () -> Value
	
	/// A function that writes a given value.
	private let set: Mutator
	public typealias Mutator = @Sendable (Value) -> ()
	
}
