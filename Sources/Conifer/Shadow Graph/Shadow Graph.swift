// Conifer © 2019–2021 Constantino Tsarouhas

import DepthKit

/// A tree data structure of vertices produced by components during rendering.
///
/// A shadow graph is the runtime equivalent of a component tree, i.e., the tree of components formed by components defining components in their `body`. While components are stateless, shadow graphs are stateful.
///
/// A shadow graph consists of two types of vertices: artefacts and structures. Artefacts form the output of a rendering pass whereas structures are merely used for dependency management and state storage. Some components may also produce hidden artefacts which do not appear in the rendering output but continue to preserve their state. When an artefact is hidden, its descendents are also hidden.
///
/// A shadow graph is constructed in pre-order. The renderer first renders the root component by invoking its `render(in:at:)` method and passing an empty shadow graph and a location to the root vertex. The root component then produces artefacts using the `produce(_:at:hidden:)` method and renders components using the `render(_:at:hidden:)` method. When the latter method is invoked, the renderer invokes the rendered component's `render(in:at:)` method before returning from the `render(_:at:hidden:)` call.
///
/// Every vertex in the shadow graph has a unique location, which is a path of identifiers for each ancestor starting from the root vertex. Artefacts can be produced and components can be rendered at any location. The shadow graph graph automatically creates structures for any inexistent ancestor vertices.
public struct ShadowGraph<Artefact : Conifer.Artefact> : ShadowGraphProtocol {
	
	/// The artefacts in the graph, keyed by location.
	private var artefactsByLocation = [Location : Artefact]()
	
	/// The locations of explicitly hidden vertices.
	///
	/// The set of effectively hidden vertices is the set of explicitly hidden locations and all locations that are descendents thereof.
	private var hiddenLocations = Set<Location>()
	
	// See protocol.
	public mutating func produce(_ artefact: Artefact, at location: Location, hidden: Bool) {
		let previous = artefactsByLocation.updateValue(artefact, forKey: location)
		if hidden {
			hiddenLocations.insert(location)
		}
		if let previous = previous {
			preconditionFailure("Cannot replace \(previous) with \(artefact) at \(location). Artefacts can only be added to shadow graphs, not replaced or deleted.")
		}
	}
	
	// See protocol.
	public mutating func render<C : Component>(_ component: C, at location: Location, hidden: Bool) {
		TODO.unimplemented
	}
	
}

public protocol ShadowGraphProtocol {
	
	/// An artefact in shadow graphs of type `Self`.
	associatedtype Artefact : Conifer.Artefact
	
	/// Inserts given artefact at given location in the graph.
	///
	/// - Parameters:
	///    - component: The artefact to produce.
	///    - location: The new location of `artefact`.
	///    - hidden: `true` if `artefact` and its descendents are hidden from the rendering output; otherwise `false`.
	mutating func produce(_ artefact: Artefact, at location: Location, hidden: Bool)
	
	/// Renders given component at the current location in the graph.
	///
	/// - Parameters:
	///    - component: The component to render.
	///    - location: The proposed location of the vertices produced by `component`.
	///    - hidden: `true` if the artefacts produced by `component` and their descendents are hidden from the rendering output; otherwise `false`.
	mutating func render<C : Component>(_ component: C, at location: Location, hidden: Bool)
	
}

extension ShadowGraphProtocol {
	
	/// Inserts given artefact at given location in the graph.
	///
	/// - Parameters:
	///    - component: The artefact to produce.
	///    - location: The new location of `artefact`.
	public mutating func produce(_ artefact: Artefact, at location: Location) {
		produce(artefact, at: location, hidden: false)
	}
	
	/// Renders given component at the current location in the graph.
	///
	/// - Parameters:
	///    - component: The component to render.
	///    - location: The proposed location of the vertices produced by `component`.
	public mutating func render<C : Component>(_ component: C, at location: Location) {
		render(component, at: location, hidden: false)
	}
	
}
