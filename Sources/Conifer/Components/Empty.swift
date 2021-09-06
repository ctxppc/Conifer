// Conifer © 2019–2021 Constantino Tsarouhas

/// The empty component; a component that represents a component with no body.
///
/// ## Shadow Graph Semantics
///
/// The empty component is not represented in the shadow graph: no artefacts are produced during rendering.
public struct Empty<Artefact> : Component {
	
	// See protocol.
	public var body: Never<Artefact> {
		Never.hasNoBody(self)
	}
	
	// See protocol.
	public func render<G : ShadowGraphProtocol>(in graph: inout G, at location: ShadowGraphLocation) async where Artefact == G.Artefact {
		// render nothing
	}
	
}
