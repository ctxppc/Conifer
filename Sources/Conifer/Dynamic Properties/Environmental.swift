// Conifer © 2019–2023 Constantino Tsarouhas

import DepthKit

/// A dynamic property whose value is provided by an ancestor component.
///
/// Accessing an environmental value that is not specified by an ancestor is not permitted.
@propertyWrapper
public struct Environmental<Value> {
	
	/// Creates an environmental property.
	///
	/// - Parameter keyPath: The keypath from an environment to the environmental value.
	public init(_ keyPath: KeyPath<Environment, Value>) {
		self.keyPath = keyPath
	}
	
	/// The keypath from an environment to the environmental value.
	let keyPath: KeyPath<Environment, Value>
	
	/// The environmental value.
	///
	/// This property may not be accessed.
	public var wrappedValue: Value {
		storedValue !! "\(keyPath) is not available outside a component"
	}
	
	/// The stored environmental value.
	fileprivate var storedValue: Value?
	
}
