// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

/// A shadow over a `Subject`.
///
/// Conifer instantiates values of this type; you do not need to do so yourself unless you recreate shadows from a previously stored graph and location or from an unowned shadow.
///
/// In most cases, except in one case detailled below, you do not need to refer to `OwnedShadow`. Use an opaque or existing type conforming to `Shadow` instead, e.g., `some Shadow<some Element>` or `any ElementShadow` where `ElementShadow` is defined as `protocol ElementShadow : Shadow where Subject : Element`.
///
/// When specialising `Shadow`, as in the example of `ElementShadow` above, add a conformance of `OwnedShadow` to your specialisation. See `Shadow` for more information.
public struct OwnedShadow<Subject : Component> : Shadow {
	
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
