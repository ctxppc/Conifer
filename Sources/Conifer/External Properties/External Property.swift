// Conifer © 2019–2020 Constantino Tsarouhas

/// A property of a component whose value is determined outside of the component.
///
/// External properties are a mechanism wherein components can retrieve information that hasn't been passed down through traditional means (e.g., during initialisation). These values might be provided by ancestor components (cf. `Contextual`) or from an external source such as a database.
///
/// External properties can only be declared within components and only be used from within a rendering context such as the `body` property or the `update(_:at:)` method. The system ensures that all declared external properties are properly populated before rendering begins. Additionally, the system records these properties as dependencies of the component; whenever any property changes, the system re-renders the component.
public protocol ExternalProperty {
	
	/// The property's value.
	var wrappedValue: Value { get }
	
	/// The value type of properties of this type.
	associatedtype Value
	
}
