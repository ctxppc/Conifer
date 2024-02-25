// Conifer © 2019–2024 Constantino Tsarouhas

/// A property of a component whose value is determined outside of the component.
///
/// Dynamic properties are a mechanism wherein components can retrieve information that hasn't been passed down through traditional means like during initialisation. These values might be provided by ancestor components (cf. `Contextual`) or from an external source such as a database.
///
/// A dynamic property can only be declared within a component (the *dependent component*) and only be used from within a rendering context such as the `body` property. The system ensures that all declared dynamic properties are properly populated before rendering begins. Additionally, the system records these properties as dependencies of the component; whenever any dynamic property changes, the system re-renders the component.
///
/// Just like a component, a dynamic property can also declare dynamic properties itself. These nested properties automatically become dependencies of the containing property's dependent component. `wrappedValue` is often defined as a `@State` property.
public protocol DynamicProperty {
	
	/// Creates a dependency for the component at `location`.
	///
	/// - Parameters:
	///   - location: The (absolute) location of the dependent component.
	///   - propertyIdentifier: A value that persistently identifies the property among other properties on the dependent component.
	///
	/// - Returns: An actor that tracks changes to `self`'s value.
	func makeDependency(forComponentAt location: Location, propertyIdentifier: some Hashable) -> Dependency
	associatedtype Dependency : Conifer.Dependency
	
	/// Updates the value of `self`.
	///
	/// The system invokes this method before the first rendering of the dependent component and after it observes one or more changes to the dependency returned by `makeDependency(forComponentAt:propertyIdentifier:)`.
	///
	/// This method is nonmutating since any state needs to be tracked using dynamic properties such as `@State` properties.
	///
	/// - Parameters:
	///   - dependency: An actor that tracks changes to `self`'s value.
	///   - change: The last change to the dependency, or `nil` if no change has been observed yet.
	func update(dependency: Dependency, change: Dependency.Change?) async throws
	
	/// The property's value.
	///
	/// `wrappedValue` is usually implemented as a `@State` property or as a computed property deriving its value from one or more `@State` properties.
	///
	/// `wrappedValue` is unspecified before the first invocation of `update(dependency:change:)`.
	var wrappedValue: Value { get }
	associatedtype Value
	
}
