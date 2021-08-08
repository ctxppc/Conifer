// Conifer © 2019–2021 Constantino Tsarouhas

import DepthKit

/// A data structure consisting of artefacts and vertices produced by components during rendering.
///
/// A shadow graph is a tree structure in two views: the artefact view and the vertex view. The artefact view consists of artefacts which mirror the hierarchy of the components. The vertex view consists of vertices which mirror the desired output of the rendering process.
///
/// Each artefact consists of zero or more subtrees of vertices. A vertex's children can be other vertices in the same artefact or root vertices of a different artefact. In every artefact except the root artefact, every root vertex is the child of a vertex in another artefact. In root artefacts, root vertices do not have a parent vertex.
///
/// A shadow graph is constructed in pre-order. The renderer creates an artefact for the root component, then invokes `render(in:context:)` on the component. The component configures the artefact, creates zero or more subtrees of vertices, and renders zero or more components as children of vertices it created. The renderer then proceeds rendering those components.
///
/// A shadow graph tracks accesses by a component while it's being rendered and registers these as dependencies. When a dependency changes, the artefact is marked stale. Stale artefacts are re-rendered during the renderer's next rendering pass.
public struct ShadowGraph<Artefact : Conifer.Artefact> {
	
	public typealias Vertex = Artefact.Vertex
	
	/// The artefacts in the graph, keyed by location.
	private var artefactsByLocation = [Location : Artefact]()
	
	/// Inserts given vertex at given location in the graph.
	///
	/// - Parameter vertex: The vertex to produce.
	public mutating func insertVertex(_ vertex: Vertex, at location: Location, in artefact: Artefact) {
		TODO.unimplemented
	}
	
	/// Removes the vertex at given location from the graph.
	///
	/// - Parameter location: The location of the vertex to remove.
	public mutating func removeVertex(at location: Location, in artefact: Artefact) {
		TODO.unimplemented
	}
	
	/// Renders given component at the current location in the graph.
	///
	/// - Parameter component: The component to render.
	///
	/// - Returns: The artefacts produced by `component`.
	public mutating func render<C : Component>(_ component: C, at location: Location) {
		TODO.unimplemented
	}
	
}
