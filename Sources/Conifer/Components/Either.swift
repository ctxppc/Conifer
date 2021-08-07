// Conifer © 2019–2021 Constantino Tsarouhas

/// A conditional component; a component that renders one of two components.
///
/// # Shadow Graph Semantics
/// 
/// The conditional component is not represented in the shadow graph; it renders the wrapped component directly at the graph location proposed to the conditional component.
public enum Either<First : Component, Second : Component> {
	
	// TODO
	
	/// The first component is rendered.
	case first(First)
	
	/// The second component is rendered.
	case second(Second)
	
	// See protocol.
	public var body: Empty<Artefact, Context> {
		.init()
	}
	
	// See protocol.
	public typealias Artefact = First.Artefact
	
	// See protocol.
	public typealias Context = First.Context
	
}

public func ??<First, Second>(first: First?, second: Second) -> Either<First, Second> {
	first.map { .first($0) } ?? .second(second)
}
