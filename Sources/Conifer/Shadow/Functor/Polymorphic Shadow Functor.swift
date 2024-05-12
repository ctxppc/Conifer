// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit

/// A functor that can be applied to an untyped shadow and is built from one or more typed shadow functors.
///
/// The appropriate typed shadow functor is selected based on the component type.
public struct PolymorphicShadowFunctor<Result> {
	
	/// Creates a functor that always produces `nil`.
	fileprivate init() {}
	
	/// The functors keyed by component type.
	private var functorsByComponentType = [ObjectIdentifier : any TypedShadowFunctorProtocol<Result>]()
	
	/// Returns a copy of `self` that applies a given function to shadows of a given component type.
	public func match<C : Component>(_ type: C.Type, do function: @escaping (any Shadow<C>) -> Result) -> Self {
		with(self) {
			$0.functorsByComponentType[.init(type)] = TypedShadowFunctor(function: function)
		}
	}
	
	/// Applies `self` on a given untyped shadow.
	///
	/// - Returns: The result of the function applied on `shadow`, or `nil` if `self` does not have a function for the underlying component type.
	fileprivate func apply(on shadow: some Shadow) async throws -> Result? {
		guard let functor = functorsByComponentType[.init(type(of: try await shadow.subject))] else { return nil }
		return try await functor.apply(on: shadow)
	}
	
}

/// Returns a functor that applies a given function to shadows of a given component type.
public func match<C : Component, Result>(_ type: C.Type, do function: @escaping (any Shadow<C>) -> Result) -> PolymorphicShadowFunctor<Result> {
	PolymorphicShadowFunctor().match(type, do: function)
}

/// A functor that can be applied to untyped shadows over a specific type of components.
private protocol TypedShadowFunctorProtocol<Result> {
	
	/// Applies the functor on a given shadow.
	///
	/// - Requires: The shadowed component is of the type expected by the functor.
	func apply(on shadow: some Shadow) async throws -> Result
	associatedtype Result
	
}

/// A functor that can be applied to shadows of a given type of components.
private struct TypedShadowFunctor<ComponentType : Component, Result> : TypedShadowFunctorProtocol {
	
	/// The function to apply on a typed shadow.
	let function: (any Shadow<ComponentType>) async throws -> Result
	
	/// Applies the functor on given typed shadow.
	func apply(on shadow: some Shadow) async throws -> Result {
		guard let shadow = shadow as? any Shadow<ComponentType> else { preconditionFailure("Expected \(shadow) to be over a \(ComponentType.self)") }
		return try await function(shadow)
	}
	
}

extension Shadow {
	
	/// Applies a given functor on the shadow.
	///
	/// - Returns: The result of `functor` applied on `self`, or `nil` if `functor` does not have a function for the underlying component type.
	public func apply<Result>(_ functor: PolymorphicShadowFunctor<Result>) async throws -> Result? {
		try await functor.apply(on: self)
	}
	
}
