// Conifer © 2019–2021 Constantino Tsarouhas

/// The empty component; a component that represents a component with no body.
///
/// ## Shadow Graph Semantics
///
/// The empty component's artefact contains no nodes.
public struct Empty<Artefact : Conifer.Artefact, Context> : Component {
	
	// See protocol.
	public var body: Self {
		Empty()
	}
	
	// See protocol.
	public func render(in graph: inout ShadowGraph<Artefact>, context: Context) async {
		// render nothing
	}
	
}
