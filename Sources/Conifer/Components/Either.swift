// Conifer © 2019–2021 Constantino Tsarouhas

/// A conditional component; a component that renders one of two components.
///
/// Conifer clients that specialise `Component` should add a conditional conformance of `Either` to that protocol. For example, a web application framework that specialises `Component` as `Element` should add the following conformance:
///
///     extension Either : Element where First : Element, Second : Element {}
///
/// ## Shadow Graph Semantics
///
/// The conditional component is not represented in the artefact graph; it renders the wrapped component directly at the graph location proposed to the conditional component.
///
/// The conditional component has a persistent identity for `first` and another for `second`. This means that state of descendant components is dependent on which branch of the conditional component is taken, but state under a branch is persisted through a change of presented branch.
public enum Either<First : Component, Second : Component> : Component {
	
	/// The first component is rendered.
	case first(First)
	
	/// The second component is rendered.
	case second(Second)
	
	// See protocol.
	public var body: Never<Artefact> {
		fatalError("\(self) has no body.")
	}
	
	// See protocol.
	public func render(in graph: inout ShadowGraph<Artefact>, at location: ShadowGraphLocation) async {
		TODO.unimplemented
	}
	
	// See protocol.
	public typealias Artefact = First.Artefact
	
}

public func ??<First, Second>(first: First?, second: Second) -> Either<First, Second> {
	first.map { .first($0) } ?? .second(second)
}
