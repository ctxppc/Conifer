// Conifer © 2019–2025 Constantino Tsarouhas

import Foundation

/// A property identifying the component's location in the shadow graph.
///
/// A location, and thus a structural identifier, uses the following elements:
/// * the position of components in static foundational components such as `Either` and `Group`
/// * the element's identifier in mapping components (`ForEach`)
///
/// A location can be considered stable if identifiers in mapping components are assigned correctly between renderings.
@propertyWrapper
public struct StructuralIdentifier : DynamicProperty {
	
	/// Creates a structural identifier.
	public init() {}
	
	// See protocol.
	public mutating func update<Component>(for shadow: some Shadow<Component>, keyPath: Self.KeyPath<Component>) async throws {
		wrappedValue = try JSONEncoder().encode(shadow.location)	// TODO: Replace with more compact encoder (Protobuf?)
	}
	
	// See protocol.
	public private(set) var wrappedValue: Data = .init()
	
}
