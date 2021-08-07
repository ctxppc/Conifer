// Conifer © 2019–2021 Constantino Tsarouhas

import DepthKit

/// A data structure consisting of artefacts produced by components.
///
/// A shadow graph persists artefacts produced by components during rendering and records their hierarchical structure. In addition, a shadow graph records the dependencies of each artefacts and invalidates artefacts whose dependencies change.
///
/// # Rendering Components & Producing Artefacts
///
/// A shadow graph is constructed in pre-order. The renderer invokes `render(in:context:)` on the root component, which may produce artefacts and render additional components. The renderer then invokes `render(in:context:)` on the first rendered component, and so on until the complete graph has been traversed. When the shadow graph is updated, the renderer re-renders components whose inputs have changed.
///
/// When the `render(in:context:)` method is invoked on a component, the component produces its artefacts in the provided shadow graph by invoking `produce(_:)`. These artefacts are inserted in the shadow graph's current render location.
public struct ShadowGraph<Artefact> {
	
	/// The artefacts in the graph, keyed by location.
	private var artefactsByLocation = [Location : Artefact]()
	
	/// The location in the graph where artefacts are rendered.
	private var renderLocation: Location
	
	/// Renders given component at the current location in the graph.
	///
	/// - Parameter component: The component to render.
	///
	/// - Returns: The artefacts produced by `component`.
	public mutating func render<C : Component>(_ component: C, context: C.Context) -> [Artefact] {
		TODO.unimplemented
	}
	
	/// Produces given artefact at the current location in the graph.
	///
	/// - Parameter artefact: The artefact to produce.
	public mutating func produce(_ artefact: Artefact) {
		TODO.unimplemented
	}
	
	/// Produces given artefact at the current location in the graph, then executes given function that manipulates the artefacts' contents.
	///
	/// - Parameter artefact: The artefact to produce.
	/// - Parameter contents: A function that manipulates the contents of `artefact` in the shadow graph.
	public mutating func produce(_ artefact: Artefact, contents: (inout ShadowGraph) -> ()) {
		contents(&self)
		TODO.unimplemented
	}
	
	/// Produces given artefacts at the current location in the graph.
	///
	/// - Parameter artefacts: The artefacts to produce.
	public mutating func produce<S : Sequence>(_ artefacts: S) where S.Element == Artefact {
		TODO.unimplemented
	}
	
}
