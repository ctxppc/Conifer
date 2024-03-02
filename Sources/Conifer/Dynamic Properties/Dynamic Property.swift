// Conifer © 2019–2024 Constantino Tsarouhas

/// A property of a component whose value is determined outside of the component.
///
/// Dynamic properties are a mechanism wherein components can retrieve information that hasn't been passed down through traditional means like during initialisation. These values might be provided by ancestor components (cf. `Contextual`) or from an external source such as a database.
///
/// A dynamic property can only be declared within a component (the *dependent component*) or within another dynamic property, and can only be used from within a rendering context such as the `body` property. The system ensures that all declared dynamic properties are properly populated before rendering begins. Additionally, the system records these properties as dependencies of the component; whenever any dynamic property changes, the system re-renders the component.
///
/// Just like a component, a dynamic property can also declare dynamic properties itself. These nested properties automatically become dependencies of the containing property's dependent component. `wrappedValue` is often defined as a `@State` property.
public protocol DynamicProperty : Sendable {
	
	/// Creates a dependency for the component at `location`.
	///
	/// - Parameters:
	///   - location: The (absolute) location of the dependent component.
	///   - propertyIdentifier: A value that persistently identifies the property among other properties on the (same) dependent component.
	///
	/// - Returns: An actor that tracks changes to `self`'s value.
	func makeDependency(forComponentAt location: Location, propertyIdentifier: some Hashable) -> Dependency
	associatedtype Dependency : Conifer.Dependency
	
	/// Updates the value of `self`.
	///
	/// The system invokes this method before the first rendering of the dependent component and after it observes one or more changes to the dependency returned by `makeDependency(forComponentAt:propertyIdentifier:)`. If `self` has any dynamic properties, they are populated or updated before this method is invoked. The system invalidates the dependent component's body whenever any dynamic property's value changes.
	///
	/// Any state on `self` must be tracked using dynamic properties such as `@State` properties. This method is therefore nonmutating.
	///
	/// - Parameters:
	///   - dependency: An actor that tracks changes to `self`'s value.
	///   - change: The last change to the dependency, or `nil` if the value is being populated for the first time.
	func update(dependency: Dependency, change: Dependency.Change?) async throws
	
	/// The property's value.
	///
	/// This property is usually implemented as a computed property deriving its value from one or more `@State` properties.
	///
	/// - Warning: `wrappedValue` is unspecified before the first invocation of `update(dependency:change:)`.
	///
	/// - Warning: This property must be accessed from within a rendering context, e.g., in a component's `body` getter or a dynamic property's `update(dependency:change:)` method, or within an update context (see `Shadow.update(_:)`).
	var wrappedValue: Value { get }
	associatedtype Value
	
}
