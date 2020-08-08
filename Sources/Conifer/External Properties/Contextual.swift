// Conifer © 2019–2020 Constantino Tsarouhas

import DepthKit

/// An external property whose value is provided by an ancestor component.
///
/// Accessing a contextual value that is not specified by an ancestor is not permitted.
@propertyWrapper
public struct Contextual<Value> {
	
	/// Creates a contextual property.
	///
	/// - Parameter keyPath: The keypath from a context to the contextual value.
	public init(_ keyPath: KeyPath<Context, Value>) {
		self.keyPath = keyPath
	}
	
	/// The keypath from a context to the contextual value.
	let keyPath: KeyPath<Context, Value>
	
	/// The contextual value.
	///
	/// This property may not be accessed.
	public var wrappedValue: Value {
		storedValue !! "\(keyPath) is not available outside a component"
	}
	
	/// The stored contextual value.
	fileprivate var storedValue: Value?
	
}
