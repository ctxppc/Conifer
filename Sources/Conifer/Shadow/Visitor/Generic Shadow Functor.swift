// Conifer © 2019–2024 Constantino Tsarouhas

/// A functor that can be applied to an untyped shadow and which is defined over a generically typed shadow.
public protocol GenericShadowFunctor<Result> {
	
	/// Applies `self` on a given typed shadow for some component type.
	func apply(on shadow: Shadow<some Component>) async throws -> Result
	associatedtype Result
	
}

extension GenericShadowFunctor {
	
	/// Applies `self` on a given untyped shadow.
	public func apply(on shadow: UntypedShadow) async throws -> Result {
		try await apply(subject: shadow.subject, graph: shadow.graph, location: shadow.location)
	}
	
	/// Applies `self` on a given subject of some component type at a given location in a given graph.
	///
	/// - Parameters:
	///   - subject: The subject on which to apply `self`. The argument is only used by the Swift runtime to open an `any Component` existential and create an appropriate `Shadow` type.
	///   - graph: The shadow graph on which to apply `self`.
	///   - location: The location of the shadow on which to apply `self`.
	///
	/// - Returns: The result of the functor.
	private func apply<C : Component>(subject: C, graph: ShadowGraph, location: Location) async throws -> Result {
		try await apply(on: Shadow<C>(graph: graph, location: location))
	}
	
}

extension UntypedShadow {
	
	/// Applies a given functor on the shadow.
	///
	/// - Returns: The result of `visitor` applied on `self`, or `nil` if `visitor` does not have a function for the underlying component type.
	public func apply<Result>(_ visitor: some GenericShadowFunctor<Result>) async throws -> Result? {
		try await visitor.apply(on: self)
	}
	
}
