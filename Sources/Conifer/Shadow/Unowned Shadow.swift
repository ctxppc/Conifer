// Conifer © 2019–2025 Constantino Tsarouhas

/// A shadow that has an unowned reference to its graph.
///
/// Unowned shadows can safely be stored as part of a shadow graph, such as an `@State` value, a contextual value, or a shadow value.
///
/// Accessing an unowned shadow after its graph is deallocated is an error and will terminate the program. Prefer using ordinary `Shadow` values when they are not stored in the shadow graph.
public struct UnownedShadow<Subject : Component> : Shadow {
	
	public init(graph: ShadowGraph, location: Location) {
		self.graph = graph
		self.location = location
	}
	
	public unowned let graph: ShadowGraph
	
	public let location: Location
	
}
