// Conifer © 2019–2021 Constantino Tsarouhas

/// The empty component; a component that represents a component with no body.
///
/// # Shadow Graph Semantics
///
/// The empty component has no representation in the shadow graph.
public struct Empty<Artefact, Context> {
	
	// See protocol.
	public var body: Empty {
		Empty()
	}
	
	// TODO
	
}
