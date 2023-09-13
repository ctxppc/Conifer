// Conifer © 2019–2023 Constantino Tsarouhas

import Foundation

/// A property of a component whose value is determined outside of the component.
///
/// Dynamic properties are a mechanism wherein components can retrieve information that hasn't been passed down through traditional means like during initialisation. These values might be provided by ancestor components (cf. `Contextual`) or from an external source such as a database.
///
/// Dynamic properties can only be declared within components and only be used from within a rendering context such as the `body` property. The system ensures that all declared dynamic properties are properly populated before rendering begins. Additionally, the system records these properties as dependencies of the component; whenever any dynamic property changes, the system re-renders the component.
public protocol DynamicProperty {
	
	/// Creates a dependency for the component at `location` through the dynamic property at `propertyKeyPath`.
	///
	/// - Parameters:
	///   - location: The (absolute) location of the dependent component.
	///   - propertyKeyPath: The key path from the dependent component to `self`.
	///
	/// - Returns: An actor that tracks changes to `self`'s value.
	func makeDependency<C : Component>(
		forComponentAt location:	Location,
		propertyAt propertyKeyPath:	KeyPath<C, Self>
	) -> Dependency
	associatedtype Dependency : Conifer.Dependency
	
	/// Returns the value of `self`.
	///
	/// - Parameters:
	///   - dependency: An actor that tracks changes to `self`'s value.
	///   - change: The last change to the dependency, or `nil` if no change has been observed yet.
	///
	/// - Returns: The value of `self`.
	func value(dependency: Dependency, change: Dependency.Change?) async throws -> Value
	associatedtype Value
	
}

extension DynamicProperty {
	
	@available(*, unavailable, message: "Dynamic properties are only available in components")
	public var wrappedValue: Value {
		preconditionFailure("@\(Self.self) is only available in components")
	}
	
	public static subscript <C : Component>(_enclosedSelf component: C, wrapped: KeyPath<C, Value>, storage: KeyPath<C, Self>) -> Value {
		TODO.unimplemented
	}
	
}
