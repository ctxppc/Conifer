// Conifer © 2019–2020 Constantino Tsarouhas

/// A conditional component; a component that renders one of two components.
///
/// # Shadow Graph Semantics
/// 
/// The conditional component is not represented in the shadow graph; it renders the wrapped component directly at the graph location proposed to the conditional component.
public enum Either<First : Component, Second : Component> : Component where First.ShadowElement == Second.ShadowElement {
	
	/// The first component is rendered.
	case first(First)
	
	/// The second component is rendered.
	case second(Second)
	
	// See protocol.
	public var body: Empty<ShadowElement> {
		.init()
	}
	
	// See protocol.
	public func update(_ graph: inout ShadowGraph<ShadowElement>, at proposedLocation: ShadowGraphLocation, context: ()?) {
		TODO.unimplemented
	}
	
	// See protocol.
	public typealias ShadowElement = First.ShadowElement
	
}

public func ??<First, Second>(first: First?, second: Second) -> Either<First, Second> {
	first.map { .first($0) } ?? .second(second)
}
