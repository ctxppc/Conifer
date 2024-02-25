// Spin © 2019–2024 Constantino Tsarouhas

/// A parameter attribute that constructs components from closures.
@resultBuilder
public struct ComponentBuilder {
	
	public static func buildIf<C>(_ component: C?) -> Either<C, Empty> {
		component.map { .first($0) } ?? .second(.init())
	}
	
	public static func buildEither<A, B>(first: A) -> Either<A, B> {
		.first(first)
	}
	
	public static func buildEither<A, B>(second: B) -> Either<A, B> {
		.second(second)
	}
	
	public static func buildBlock() -> Empty {
		.init()
	}
	
	public static func buildBlock<C : Component>(_ component: C) -> C {
		component
	}
	
	public static func buildBlock<each Child>(_ child: repeat each Child) -> Group<repeat each Child> {
		Group(repeat each child)
	}
	
}
