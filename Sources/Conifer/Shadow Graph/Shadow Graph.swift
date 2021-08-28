// Conifer © 2019–2021 Constantino Tsarouhas

import DepthKit

/// A tree data structure of vertices produced by components during rendering.
///
/// A shadow graph is the runtime equivalent of a component tree, i.e., the tree of components formed by components defining components in their `body`. While components are stateless, shadow graphs are stateful.
///
/// A shadow graph consists of two types of vertices: artefacts and structures. Artefacts form the output of a rendering pass whereas structures are merely used for dependency management and state storage. Some components may also produce hidden artef	acts which do not appear in the rendering output but continue to preserve their state. When an artefact is hidden, its descendents are also hidden.
///
/// A shadow graph is constructed in pre-order. The renderer first renders the root component by invoking its `render(in:at:)` method and passing an empty shadow graph and a location to the root vertex. The root component then produces artefacts using the `produce(_:at:hidden:)` method and renders components using the `render(_:at:hidden:)` method. When the latter method is invoked, the renderer invokes the rendered component's `render(in:at:)` method before returning from the `render(_:at:hidden:)` call.
///
/// Every vertex in the shadow graph has a unique location, which is a path of identifiers for each ancestor starting from the root vertex. Artefacts can be produced and components can be rendered at any location. The shadow graph graph automatically creates structures for any inexistent ancestor vertices.
///
/// During a component's `render(in:at:)` call, the shadow graph tracks accesses by that component and registers these as dependencies. When a dependency changes, all cached artefacts during that method call are invalidated
public struct ShadowGraph<Artefact : Conifer.Artefact> {
	
	/// The artefacts in the graph, keyed by location.
	private var artefactsByLocation = [Location : Artefact]()
	
	/// Inserts given artefact at given location in the graph.
	///
	/// - Parameters:
	///    - component: The artefact to produce.
	///    - location: The new location of `artefact`.
	///    - hidden: `true` if `artefact` and its descendents are hidden from the rendering output; otherwise `false`. The default value is `false`.
	public mutating func produce(_ artefact: Artefact, at location: Location, hidden: Bool = false) {
		TODO.unimplemented
	}
	
	/// Renders given component at the current location in the graph.
	///
	/// - Parameters:
	///    - component: The component to render.
	///    - location: The proposed location of the vertices produced by `component`.
	///    - hidden: `true` if the artefacts produced by `component` and their descendents are hidden from the rendering output; otherwise `false`. The default value is `false`.
	public mutating func render<C : Component>(_ component: C, at location: Location, hidden: Bool = false) {
		TODO.unimplemented
	}
	
	// - MARK: Dependency Tracking
	
	/// The dependencies of the component currently being rendered, or `nil` if dependency tracking is not active.
	private var dependencies: DependencySet?
	
	/// A value describing the dependencies of a component.
	struct DependencySet : Equatable {
		
		/// The graph locations created during rendering.
		var createdLocations: Set<Location> = []
		
		/// The graph locations accessed during rendering.
		var accessedLocations: Set<Location> = []
		
	}
	
	/// Performs a rendering function on `self` while tracking dependencies.
	mutating func withDependencyTracking(render: (inout Self) -> ()) -> DependencySet {
		assert(dependencies == nil, "Cannot start tracking dependencies while already tracking dependencies")
		dependencies = .init()
		defer { dependencies = nil }
		render(&self)
		return dependencies !! "Expected dependency set at end of tracking dependencies"
	}
	
}
