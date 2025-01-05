// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

/// A shadow over a `Subject`.
///
/// Conifer instantiates values of this type; you do not need to do so yourself.
///
/// In most cases, except in one case detailled below, you do not need to refer to `ShadowType`. Use an opaque or existing type conforming to `Shadow` instead, e.g., `some Shadow<some Element>` or `any ElementShadow` where `ElementShadow` is defined as `protocol ElementShadow : Shadow where Subject : Element`.
///
/// When specialising `Shadow`, as in the example of `ElementShadow` above, add a conformance of `ShadowType` to your specialisation. See `Shadow` for more information.
@dynamicMemberLookup
public struct ShadowType<Subject : Component> : Shadow {
	
	// See protocol.
	public init(graph: ShadowGraph, location: ShadowGraph.Location) {
		self.graph = graph
		self.location = location
	}
	
	// See protocol.
	public let graph: ShadowGraph
	
	// See protocol.
	public let location: ShadowGraph.Location
	
}
