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
	fileprivate var snapshotsbyLocation = [Location : ShadowSnapshot]()
	
	/// Accesses the shadow snapshot of the component at given location relative to the root component.
	subscript (location: Location) -> ShadowSnapshot {
		get { snapshotsbyLocation[location] ?? .init() }
		_modify { yield &snapshotsbyLocation[location, default: .init()] }
	}
	
	/// Returns a shadow over the component at a given location.
	func shadow(at location: Location) async throws -> any Shadow {
		if let type = self[location].subjectType {
			return type.makeUntypedShadow(graph: self, location: location)
		} else {
			let parentLocation = location.parent !! "Expected root component to have a known subject type"
			let parentComponent = try await shadow(at: parentLocation).subject
			if let parentComponent = parentComponent as? any FoundationalComponent {
				return try await parentComponent
					.typeOfChild(at: location, in: self)
					.makeUntypedShadow(graph: self, location: location)
			} else {
				return parentComponent.makeUntypedShadowForBody(graph: self, bodyLocation: location)
			}
		}
	}
	
}

private extension Component {
	func makeUntypedShadowForBody(graph: ShadowGraph, bodyLocation: ShadowGraph.Location) -> any Shadow {
		Body.makeUntypedShadow(graph: graph, location: bodyLocation)
	}
}
