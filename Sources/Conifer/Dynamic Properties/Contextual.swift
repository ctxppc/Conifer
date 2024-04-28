// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit

/// A dynamic property whose value is provided by an ancestor component.
///
/// Accessing a contextual value that is not specified by an ancestor is not permitted.
@propertyWrapper
public struct Contextual<Value> : DynamicProperty, @unchecked Sendable {	// KeyPath, an immutable class, is not declared Sendable
	
	/// Creates a contextual property.
	///
	/// - Parameter key: The contextual key.
	public init(_ key: Context.Key<Value>) {
		self.key = key
	}
	
	/// The contextual key.
	let key: Context.Key<Value>
	
	// See protocol.
	public mutating func update(for shadow: UntypedShadow, propertyIdentifier: some Hashable & Sendable) async throws {
		storedValue = try await shadow.context[keyPath: key]
	}
	
	// See protocol.
	public var wrappedValue: Value {
		storedValue !! "Accessing contextual value for \(key) outside rendering context"
	}
	
	/// The contextual value, or `nil` if the dependent component isn't being rendered yet.
	private var storedValue: Value?
	
}
