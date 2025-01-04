// Conifer © 2019–2025 Constantino Tsarouhas

/// A parameter attribute that constructs components from closures.
@resultBuilder
public enum ComponentBuilder {
	
	public static func buildIf<C>(_ component: C?) -> Either<C, Empty> {
		component.map { .first($0) } ?? .second(.init())
	}
	
	public static func buildEither<A, B>(first: A) -> Either<A, B> {
		.first(first)
	}
	
	public static func buildEither<A, B>(second: B) -> Either<A, B> {
		.second(second)
	}
		
	public static func buildBlock<C : Component>(_ component: C) -> C {
		component
	}
	
	public static func buildBlock<each C : Component>(_ children: repeat each C) -> Group<repeat each C> {
		.init(repeat each children)
	}
	
}
