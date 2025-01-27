// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

/// A dynamic property whose value is provided by an ancestor component.
///
/// Accessing a contextual value that is not specified by an ancestor is not permitted.
@propertyWrapper
public struct Contextual<Value : Sendable> : DynamicProperty, @unchecked Sendable {	// KeyPath, an immutable class, is not declared Sendable
	
	/// Creates a contextual property.
	///
	/// - Parameter key: The contextual key.
	public init(_ key: Context.Key<Value>) {
		self.key = key
	}
	
	/// The contextual key.
	let key: Context.Key<Value>
	
	// See protocol.
	public mutating func update<Component>(for shadow: some Shadow<Component>, keyPath: Self.KeyPath<Component>) async throws {
		storedValue = try await shadow.context[keyPath: key]
	}
	
	// See protocol.
	public var wrappedValue: Value {
		storedValue !! "Accessing contextual value for \(key) outside rendering context"
	}
	
	/// The contextual value, or `nil` if the dependent component isn't being rendered yet.
	private var storedValue: Value?
	
}
