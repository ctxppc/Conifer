// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

/// A property identifying the component's location in the shadow graph.
///
/// A location, and thus a structural identifier, uses the following elements:
/// * the position of components in static foundational components such as `Either` and `Group`
/// * the element's identifier in mapping components (`ForEach`)
///
/// A location can be considered stable if identifiers in mapping components are assigned correctly between renderings.
///
/// - Note: A `@StructuralIdentifier` value always identifies a component, even when nested within a dynamic property.
@propertyWrapper
public struct StructuralIdentifier : DynamicProperty {
	
	/// Creates a structural identifier.
	public init() {}
	
	// See protocol.
	public mutating func update<Component>(for shadow: some Shadow<Component>, keyPath: Path<Component>) {
		_wrappedValue = shadow.location
	}
	
	// See protocol.
	public var wrappedValue: ShadowGraph.Location {
		_wrappedValue !! "Cannot determine structural identifier before rendering"
	}
	
	private var _wrappedValue: ShadowGraph.Location?
	
}
