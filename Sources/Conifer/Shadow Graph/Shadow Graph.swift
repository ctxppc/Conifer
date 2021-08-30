// Conifer © 2019–2021 Constantino Tsarouhas

import DepthKit

/// A tree data structure of vertices produced by components during rendering.
///
/// A shadow graph is the runtime equivalent of a component tree, i.e., the tree of components formed by components defining components in their `body`. While components are stateless, shadow graphs are stateful.
///
/// A shadow graph consists of two types of vertices: artefacts and structures. Artefacts form the output of a rendering pass whereas structures are merely used for dependency management and state storage.
///
/// A shadow graph is constructed in pre-order. The renderer first renders the root component by invoking its `render(in:at:)` method and passing an empty shadow graph and a location to the root vertex. The root component then produces artefacts using the `produce(_:at:)` method and renders components using the `render(_:at:)` method. When the latter method is invoked, the renderer invokes the rendered component's `render(in:at:)` method before returning from the `render(_:at:)` call.
///
/// Every vertex in the shadow graph has a unique location, which is a path of identifiers for each ancestor starting from the root vertex. Artefacts can be produced and components can be rendered at any location. The shadow graph graph automatically creates structures for any inexistent ancestor vertices.
public struct ShadowGraph<Artefact : Conifer.Artefact> : ShadowGraphProtocol {
	
	/// The artefacts in the graph, keyed by location.
	private var artefactsByLocation = [Location : Artefact]()
	
	/// The locations of explicitly hidden vertices.
	///
	/// The set of effectively hidden vertices is the set of explicitly hidden locations and all locations that are descendents thereof.
	private var hiddenVertexLocations = Set<Location>()
	
	// See protocol.
	public mutating func produce(_ artefact: Artefact, at location: Location) {
		let previous = artefactsByLocation.updateValue(artefact, forKey: location)
		if let previous = previous {
			preconditionFailure("Cannot replace \(previous) with \(artefact) at \(location). Artefacts can only be added to shadow graphs, not replaced or deleted.")
		}
		precondition(!hiddenVertexLocations.contains(location), "Cannot replace hidden vertex with \(artefact) at \(location). Vertices can only be added to shadow graphs, not replaced or deleted.")
	}
	
	// See protocol.
	public mutating func render<C : Component>(_ component: C, at location: Location) {
		TODO.unimplemented
	}
	
	// See protocol.
	public mutating func produceHiddenVertex(at location: Location) {
		if let artefact = artefactsByLocation[location] {
			preconditionFailure("Cannot replace \(artefact) with hidden vertex at \(location). Vertices can only be added to shadow graphs, not replaced or deleted.")
		}
		hiddenVertexLocations.insert(location)
	}
	
}

public protocol ShadowGraphProtocol {
	
	/// An artefact in shadow graphs of type `Self`.
	associatedtype Artefact : Conifer.Artefact
	
	/// Inserts given artefact at given location in `self`.
	///
	/// - Parameters:
	///    - component: The artefact to produce.
	///    - location: The new location of `artefact`.
	mutating func produce(_ artefact: Artefact, at location: Location)
	
	/// Renders given component at the current location in the graph.
	///
	/// - Parameters:
	///    - component: The component to render.
	///    - location: The proposed location of the vertices produced by `component`.
	mutating func render<C : Component>(_ component: C, at location: Location)
	
	/// Inserts a hidden vertex at given location in `self`.
	///
	/// A hidden vertex represents an artefact or structure that is currently not part of the graph but may be present in other circumstances. By producing this vertex using this method, the shadow graph extends the lifetime of any state stored as part of the vertex or any descendents. At the end of each rendering pass, the system removes any state associated with removed vertices but preserves those of hidden vertices.
	mutating func produceHiddenVertex(at location: Location)
	
}
