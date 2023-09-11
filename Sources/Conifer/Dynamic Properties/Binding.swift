// Conifer © 2019–2023 Constantino Tsarouhas

/// A value that can read and write a value owned by a source of truth.
@propertyWrapper
public struct Binding<Value> {
	
	/// Creates a binding with given getter and setter.
	public init(get: @escaping () -> Value, set: @escaping (Value) -> ()) {
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
	private let get: () -> Value
	
	/// A function that writes a given value.
	private let set: (Value) -> ()
	
}
