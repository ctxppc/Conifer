// Conifer © 2019–2025 Constantino Tsarouhas

/// A property of a component whose value is determined outside of the component.
///
/// Dynamic properties are a mechanism wherein components can retrieve information that hasn't been passed down through traditional means like during initialisation. These values might be provided by ancestor components (cf. `Contextual`) or from an external source such as a database. The *source of truth* is said to be external to the property.
///
/// A dynamic property can only be declared within a component (the *dependent component*) or within another dynamic property. Conifer ensures that all declared dynamic properties are properly updated before the dependent component is (re)rendered and its `body` is accessed.
///
/// A dynamic property can itself declare and use dynamic properties, which the framework updates before invoking `update(for:keyPath:)`. Common nested dynamic properties are
/// * `@State` properties for storing computed values such as database results that are then vended through `wrappedValue`,
/// * `@Context` properties for reading contextual values such as a database connection, and
/// * a `@StructuralIdentity` property for identifying `self` within the shadow graph.
public protocol DynamicProperty : Sendable {
	
	/// Updates the property's value.
	///
	/// Conifer invokes this method after (re)rendering the ancestors of `shadow` and just before (re)rendering `shadow`.
	///
	/// This method updates `wrappedValue` or any properties underlying it. Additionally,
	///
	/// - Precondition: Any (nested) dynamic properties on `self` are updated. This means that this method can use those properties.
	/// - Postcondition: `self` is updated, i.e., `wrappedValue` reflects the value at the source of truth.
	///
	/// - Warning: When this method is invoked, the children of `shadow` are not (re)rendered yet and therefore should not be accessed.
	/// - Warning: `shadow.subject` is being updated and therefore cannot be accessed.
	/// - Warning: Accessing `self` via `keyPath` from within this method is a concurrent access violation.
	///
	/// - Parameter shadow: The shadow of the component being rendered.
	/// - Parameter keyPath: A key path from `shadow`'s subject to `self`.
	mutating func update<Component>(for shadow: some Shadow<Component>, keyPath: KeyPath<Component>) async throws
	typealias KeyPath<Component> = WritableKeyPath<Component, Self> & Sendable
	
	/// The property's value.
	///
	/// - Precondition: `self` has been updated, i.e., `update(for:keyPath:)` has been invoked.
	var wrappedValue: Value { get }
	associatedtype Value
	
}
