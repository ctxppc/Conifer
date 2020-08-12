// Conifer © 2019–2020 Constantino Tsarouhas

/// The empty component; a component that represents a component with no body.
///
/// # Shadow Graph Semantics
///
/// The empty component has no representation in the shadow graph.
public struct Empty<ShadowElement : Conifer.ShadowElement> : Component {
	
	// See protocol.
	public var body: Empty {
		Empty()
	}
	
	// See protocol.
	public func update(_ graph: inout ShadowGraph<ShadowElement>, at proposedLocation: ShadowGraphLocation, context: ()?) {
		// The empty component doesn't affect the shadow graph.
	}
	
}
