// Conifer © 2019–2025 Constantino Tsarouhas

/// A dynamic property whose value is provided by a descendant component.
///
/// - Note: The preferred value may be the default value until a descendant component is rendered that has an assigned preference value.
@propertyWrapper
public struct Preferred<PreferenceType : Preference> : DynamicProperty {
	
	/// Creates a preferred property.
	public init() {}
	
	// See protocol.
	public private(set) var wrappedValue: PreferenceType = .default
	
	// See protocol.
	public mutating func update<Component>(for shadow: some Shadow<Component>, keyPath: Self.KeyPath<Component>) async throws {
		// FIXME: Causes an infinite loop during the first rendering?
		wrappedValue = try await shadow.preference(ofType: PreferenceType.self)
	}
	
}
