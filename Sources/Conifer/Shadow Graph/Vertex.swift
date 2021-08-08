// Conifer © 2019–2021 Constantino Tsarouhas

/// A value that represents a part of a component in a shadow graph and is part of a subtree of an artefact.
public protocol Vertex {
	
	/// Creates a vertex with given graph location.
	init(graphLocation: GraphLocation)
	
	/// The location of the vertex in the shadow graph.
	///
	/// A shadow graph updates this property when the vertex's location changes.
	var graphLocation: GraphLocation { get set }
	
	/// A value indicating the location of a vertex in a shadow graph.
	typealias GraphLocation = ShadowGraphLocation
	
}
