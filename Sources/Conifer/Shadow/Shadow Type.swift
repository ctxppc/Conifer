// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit

/// A shadow over a `Subject`.
@dynamicMemberLookup
public struct ShadowType<Subject : Component> : Shadow {
	
	// See protocol.
	public init(graph: ShadowGraph, location: Location) {
		self.graph = graph
		self.location = location
	}
	
	// See protocol.
	public let graph: ShadowGraph
	
	// See protocol.
	public let location: Location
	
}
