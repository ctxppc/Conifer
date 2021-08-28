// Conifer © 2019–2021 Constantino Tsarouhas

/// A value that represents a component in a shadow graph and consists of zero or more subtrees of vertices in the shadow graph.
///
/// Before the system renders a component for first time, it creates an empty artefact representing it and adds it to the shadow graph. When the component is later rendered again, the component updates the artefact
public protocol Artefact {
	
	/// Creates an empty artefact with given graph location.
	init(graphLocation: ShadowGraphLocation)
	
	/// The location of the artefact in the shadow graph.
	///
	/// An artefact's location in a shadow graph does not change after the artefact is created and can therefore be used as a stable identifier.
	var graphLocation: ShadowGraphLocation { get }
	
}
