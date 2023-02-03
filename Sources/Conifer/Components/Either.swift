// Conifer © 2019–2023 Constantino Tsarouhas

/// A conditional component; a component that renders one of two components.
///
/// Conifer clients that specialise `Component` should add a conditional conformance of `Either` to that protocol. For example, a web application framework that specialises `Component` as `Element` should add the following conformance:
///
///     extension Either : Element where First : Element, Second : Element {}
///
/// ## Shadow Graph Semantics
///
/// The conditional component is not represented in the artefact view of the shadow graph; any artefacts produced by the subcomponent are located at the location proposed to the conditional component.
///
/// The conditional component has a persistent identity for `first` and another for `second`. This means that state of descendant components is dependent on which branch of the conditional component is taken, but state under a branch is persisted through a change of presented branch.
public enum Either<First : Component, Second : Component> : Component /* where First.Artefact == Second.Artefact */ {
	
	/// The first component is rendered.
	case first(First)
	
	/// The second component is rendered.
	case second(Second)
	
	// See protocol.
	public var body: Never/*<Artefact>*/ {
		Never.hasNoBody(self)
	}
	
	// See protocol.
	public func render<G : ShadowGraphProtocol>(in graph: inout G, at location: ShadowGraphLocation) async /* where G.Artefact == Artefact */ {
		switch self {
			
			case .first(let c):
			await graph.render(c, at: location[ChildIdentifier.first])
			graph.produceHiddenVertex(at: location[ChildIdentifier.second])
			
			case .second(let c):
			graph.produceHiddenVertex(at: location[ChildIdentifier.first])
			await graph.render(c, at: location[ChildIdentifier.second])
			
		}
	}
	
	private enum ChildIdentifier : Hashable {
		case first, second
	}
	
	// See protocol.
	/* public typealias Artefact = First.Artefact */
	
}

public func ??<First, Second>(first: First?, second: Second) -> Either<First, Second> {
	first.map { .first($0) } ?? .second(second)
}
