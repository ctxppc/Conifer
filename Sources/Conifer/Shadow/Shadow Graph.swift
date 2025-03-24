// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

/// A tree structure of rendered components.
///
/// Conifer clients do not create or directly interact with `ShadowGraph`s, except possibly for comparing graph identity with `===`. All other interactions happen via `Shadow`s.
public actor ShadowGraph {
	
	/// Creates a shadow graph with given root component.
	init(root: some Component) async throws {
		self[.anchor].subject = root
	}
	
	/// The latest shadow snapshots for each rendered component, keyed by location relative to the root component.
	///
	/// - Invariant: `snapshotsbyLocation[.anchor]` is not `nil`. That is, `self` contains at least a rendered root component.
	private var snapshotsbyLocation = [Location : ShadowSnapshot]()
	
	/// Accesses the shadow snapshot of the component at given location relative to the root component.
	subscript (location: Location) -> ShadowSnapshot {
		get { snapshotsbyLocation[location] ?? .init() }
		_modify { yield &snapshotsbyLocation[location, default: .init()] }
	}
	
	/// The location of the component currently being rendered, or `nil` if no component is being rendered.
	var renderingLocation: Location?	// TODO: Generalised dependency tracking?
	
}
