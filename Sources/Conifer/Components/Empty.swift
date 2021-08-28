// Conifer © 2019–2021 Constantino Tsarouhas

/// The empty component; a component that represents a component with no body.
///
/// ## Shadow Graph Semantics
///
/// The empty component is not represented in the artefact graph: no artefacts are produced during rendering.
public struct Empty<Artefact : Conifer.Artefact> : Component {
	
	// See protocol.
	public var body: Never<Artefact> {
		fatalError("\(self) has no body.")
	}
	
	// See protocol.
	public func render(in graph: inout ShadowGraph<Artefact>, at location: ShadowGraphLocation) async {
		// render nothing
	}
	
}
