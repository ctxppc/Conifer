// Conifer © 2019–2024 Constantino Tsarouhas

/// A property of a component whose value is determined outside of the component.
///
/// Dynamic properties are a mechanism wherein components can retrieve information that hasn't been passed down through traditional means like during initialisation. These values might be provided by ancestor components (cf. `Contextual`) or from an external source such as a database.
///
/// A dynamic property can only be declared within a component (the *dependent component*) or within another dynamic property. The system ensures that all declared dynamic properties are properly populated before rendering begins. Additionally, the system records these properties as dependencies of the component; whenever any dynamic property changes, the system rerenders the component.
///
/// Just like a component, a dynamic property can also declare dynamic properties itself. These nested properties automatically become dependencies of the containing property's dependent component.
public protocol DynamicProperty : Sendable {
	
	/// Updates the value of `self`.
	///
	/// The system invokes this method just before (re)rendering `shadow` and after (re)rendering the ancestors of `shadow`.
	///
	/// - Warning: When this method is invoked, the children of `shadow` may not be (re)rendered yet.
	///
	/// - Parameter shadow: The shadow of the component being rendered.
	/// - Parameter propertyIdentifier: An identifier for `self` among other properties on the dependent component.
	mutating func update(for shadow: UntypedShadow, propertyIdentifier: some Hashable & Sendable) async throws
	
	/// The property's value.
	///
	/// - Warning: `wrappedValue` is unspecified before the first invocation of `update(for:propertyIdentifier:)`.
	var wrappedValue: Value { get }
	associatedtype Value
	
}
