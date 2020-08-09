// Conifer © 2019–2020 Constantino Tsarouhas

import DepthKit

/// The empty component represents a component with no body.
public struct Empty<ShadowElement : Conifer.ShadowElement> : Component {
	
	// See protocol.
	public var body: Empty {
		Empty()
	}
	
	// See protocol.
	public func update(_ graph: inout ShadowGraph<ShadowElement>, at parentPath: ShadowGraphLocation) {
		// The empty component doesn't affect the shadow graph.
	}
	
}
