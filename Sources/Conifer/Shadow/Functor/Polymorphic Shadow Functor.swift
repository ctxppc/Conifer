// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit

/// A functor that can be applied to an untyped shadow and is built from one or more typed shadow functors.
///
/// The appropriate typed shadow functor is selected based on the component type.
public struct PolymorphicShadowFunctor<Result> {
	
	/// Creates a functor that always produces `nil`.
	fileprivate init() {}
	
	/// The visitors keyed by component type.
	private var visitorsByComponentType = [ObjectIdentifier : any TypedShadowFunctorProtocol<Result>]()
	
	/// Returns a copy of `self` that applies a given function to shadows of a given component type.
	public func match<C>(_ type: C.Type, do function: @escaping (Shadow<C>) -> Result) -> Self {
		with(self) {
			$0.visitorsByComponentType[.init(type)] = TypedShadowFunctor(function: function)
		}
	}
	
	/// Applies `self` on a given untyped shadow.
	///
	/// - Returns: The result of the function applied on `shadow`, or `nil` if `self` does not have a function for the underlying component type.
	fileprivate func apply(on shadow: UntypedShadow) async throws -> Result? {
		guard let visitor = visitorsByComponentType[.init(type(of: try await shadow.subject))] else { return nil }
		return try await visitor.apply(on: shadow)
	}
	
}

/// Returns a functor that applies a given function to shadows of a given component type.
public func match<C, Result>(_ type: C.Type, do function: @escaping (Shadow<C>) -> Result) -> PolymorphicShadowFunctor<Result> {
	PolymorphicShadowFunctor().match(type, do: function)
}

/// A functor that can be applied to untyped shadows over a specific type of components.
private protocol TypedShadowFunctorProtocol<Result> {
	
	/// Applies the functor on a given shadow.
	///
	/// - Requires: The shadowed component is of the type expected by the functor.
	func apply(on shadow: UntypedShadow) async throws -> Result
	associatedtype Result
	
}

/// A functor that can be applied to shadows of a given type of components.
private struct TypedShadowFunctor<ComponentType : Component, Result> : TypedShadowFunctorProtocol {
	
	/// The function to apply on a typed shadow.
	let function: (Shadow<ComponentType>) async throws -> Result
	
	// See protocol.
	func apply(on shadow: UntypedShadow) async throws -> Result {
		try await apply(on: Shadow(shadow) !! "Typed shadow visitor expected component typed \(ComponentType.self)")
	}
	
	/// Applies the functor on given typed shadow.
	func apply(on shadow: Shadow<ComponentType>) async throws -> Result {
		try await function(shadow)
	}
	
}

extension UntypedShadow {
	
	/// Applies a given functor on the shadow.
	///
	/// - Returns: The result of `functor` applied on `self`, or `nil` if `functor` does not have a function for the underlying component type.
	public func apply<Result>(_ functor: PolymorphicShadowFunctor<Result>) async throws -> Result? {
		try await functor.apply(on: self)
	}
	
}
