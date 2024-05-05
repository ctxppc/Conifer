// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit

/// A functor that can be applied to an untyped shadow and is built from zero typed shadow functors and a generic shadow functor.
///
/// The appropriate shadow functor is selected based on the component type.
public struct DefaultedPolymorphicShadowFunctor<FallbackFunctor : GenericShadowFunctor> {
	
	public typealias Result = FallbackFunctor.Result
	
	/// Creates a visitor.
	fileprivate init(polymorphicShadowFunctor: PolymorphicShadowFunctor<Result>, fallbackFunctor: FallbackFunctor) {
		self.polymorphicShadowFunctor = polymorphicShadowFunctor
		self.fallbackFunctor = fallbackFunctor
	}
	
	/// The wrapped polymorphic shadow functor.
	private let polymorphicShadowFunctor: PolymorphicShadowFunctor<Result>
	
	/// The wrapped generic shadow functor, used when the polymorphic shadow functor cannot handle a component type.
	private let fallbackFunctor: FallbackFunctor
	
	/// Applies `self` on a given untyped shadow.
	///
	/// - Returns: The result of the function applied on `shadow`, or `nil` if `self` does not have a function for the underlying component type.
	fileprivate func apply(on shadow: UntypedShadow) async throws -> Result {
		if let result = try await shadow.apply(polymorphicShadowFunctor) {
			return result
		} else {
			return try await fallbackFunctor.apply(on: shadow)
		}	// Nil-coalescing operator does not support effects
	}
	
}

extension PolymorphicShadowFunctor {
	
	/// Returns a copy of `self` that applies a given fallback functor on shadows whose underlying subject type isn't handled by `self`.
	public func otherwise<FF>(_ fallbackFunctor: FF) -> DefaultedPolymorphicShadowFunctor<FF> where Result == FF.Result {
		.init(polymorphicShadowFunctor: self, fallbackFunctor: fallbackFunctor)
	}
	
}

extension UntypedShadow {
	
	/// Applies a given functor on the shadow.
	///
	/// - Returns: The result of `visitor` applied on `self`, or `nil` if `visitor` does not have a function for the underlying component type.
	public func apply<F>(_ visitor: DefaultedPolymorphicShadowFunctor<F>) async throws -> DefaultedPolymorphicShadowFunctor<F>.Result {
		try await visitor.apply(on: self)
	}
	
}
