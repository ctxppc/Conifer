// Conifer © 2019–2024 Constantino Tsarouhas

/// A functor that can be applied to an untyped shadow and which is defined over a generically typed shadow.
public protocol GenericShadowFunctor<Result> {
	
	/// Applies `self` on a given typed shadow for some component type.
	func apply(on shadow: some Shadow) async throws -> Result
	associatedtype Result
	
}

extension GenericShadowFunctor {
	
	/// Applies `self` on a given untyped shadow.
	public func apply(on shadow: some Shadow) async throws -> Result {
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
		try await apply(on: subject.makeShadow(graph: graph, location: location))
	}
	
}

extension Shadow {
	
	/// Applies a given functor on the shadow.
	///
	/// - Returns: The result of `functor` applied on `self`.
	public func apply<Result>(_ functor: some GenericShadowFunctor<Result>) async throws -> Result {
		try await functor.apply(on: self)
	}
	
}
