// Spin © 2019–2024 Constantino Tsarouhas

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
	
	// TODO: Replace following methods with single buildBlock(_:) with a parameter pack when compiler issues are sorted out.
	
	public static func buildBlock() -> Empty {
		.init()
	}
	
	public static func buildBlock<C : Component>(_ component: C) -> C {
		component
	}
	
	public static func buildBlock<A, B>(_ a: A, _ b: B) -> Group<A, B> {
		.init(a, b)
	}
	
	public static func buildBlock<A, B, C>(_ a: A, _ b: B, _ c: C) -> Group<A, B>.Con<C> {
		Group(a, b).con(c)
	}

	public static func buildBlock<A, B, C, D>(_ a: A, _ b: B, _ c: C, _ d: D) -> Group<A, B>.Con<C>.Con<D> {
		Group(a, b).con(c).con(d)
	}

	public static func buildBlock<A, B, C, D, E>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) -> Group<A, B>.Con<C>.Con<D>.Con<E> {
		Group(a, b).con(c).con(d).con(e)
	}

	public static func buildBlock<A, B, C, D, E, F>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F) -> Group<A, B>.Con<C>.Con<D>.Con<E>.Con<F> {
		Group(a, b).con(c).con(d).con(e).con(f)
	}

	public static func buildBlock<A, B, C, D, E, F, G>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G) -> Group<A, B>.Con<C>.Con<D>.Con<E>.Con<F>.Con<G> {
		Group(a, b).con(c).con(d).con(e).con(f).con(g)
	}

	public static func buildBlock<A, B, C, D, E, F, G, H>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H) -> Group<A, B>.Con<C>.Con<D>.Con<E>.Con<F>.Con<G>.Con<H> {
		Group(a, b).con(c).con(d).con(e).con(f).con(g).con(h)
	}

	public static func buildBlock<A, B, C, D, E, F, G, H, I>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I) -> Group<A, B>.Con<C>.Con<D>.Con<E>.Con<F>.Con<G>.Con<H>.Con<I> {
		Group(a, b).con(c).con(d).con(e).con(f).con(g).con(h).con(i)
	}

	public static func buildBlock<A, B, C, D, E, F, G, H, I, J>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I, _ j: J) -> Group<A, B>.Con<C>.Con<D>.Con<E>.Con<F>.Con<G>.Con<H>.Con<I>.Con<J> {
		Group(a, b).con(c).con(d).con(e).con(f).con(g).con(h).con(i).con(j)
	}
	
}
