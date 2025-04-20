// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

/// A tree structure of rendered components.
///
/// Conifer clients do not create or directly interact with `ShadowGraph`s, except possibly for comparing graph identity with `===`. All other interactions happen via `Shadow`s.
public actor ShadowGraph {
	
	/// Creates a shadow graph with given root component.
	///
	/// - Requires: `root` is non-foundational.
	init(root: some Component) async {
		precondition(!(root is any FoundationalComponent), "Cannot create shadow over a foundational component.")
		self[.anchor].subject = root
	}
	
	/// The latest shadow snapshots for each rendered component, keyed by absolute location.
	///
	/// - Invariant: `snapshotsbyLocation[.anchor]` is not `nil`. That is, `self` contains at least a rendered root component.
	fileprivate var snapshotsbyLocation = [Location : ShadowSnapshot]()
	
	/// Accesses the shadow snapshot of the component at given location relative to the root component.
	subscript (location: Location) -> ShadowSnapshot {
		get { snapshotsbyLocation[location] ?? .init() }
		_modify {
			yield &snapshotsbyLocation[location, default: .init()]
			if let subscriptions = observationSubscriptionsByLocation[location] {
				let snapshot = snapshotsbyLocation[location, default: .init()]
				for subscription in subscriptions {
					subscription.observe(snapshot)
				}
			}
		}
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
	
	/// The observers of the graph, keyed by absolute location.
	fileprivate var observationSubscriptionsByLocation = [Location : [ObservationSubscription]]()
	
	/// A value representing a graph observer.
	struct ObservationSubscription : Sendable {
		
		/// The subscription's identifier, unique across the graph.
		fileprivate let id: Int
		
		/// The location of the observed shadow.
		fileprivate let location: Location
		
		/// A function invoked whenever the observed shadow changes.
		fileprivate let observe: ObserveFunction
		
	}
	
	/// The identifier of the next observation subscription.
	fileprivate var nextObservationSubscriptionID = 0
	
	/// Starts observing a shadow at a given location.
	func observeShadow(at location: Location, observe: @escaping ObserveFunction) -> ObservationSubscription {
		let subscription = ObservationSubscription(id: nextObservationSubscriptionID, location: location, observe: observe)
		nextObservationSubscriptionID += 1
		observationSubscriptionsByLocation[location, default: []].append(subscription)
		return subscription
	}
	
	/// A function invoked when a shadow has a new snapshot.
	typealias ObserveFunction = @Sendable (ShadowSnapshot) -> ()
	
	/// Stops observing a shadow using a given subscription.
	func stopObserving(subscription: ObservationSubscription) {
		observationSubscriptionsByLocation[subscription.location]?.removeAll(where: { $0.id == subscription.id })
	}
	
}

private extension Component {
	func makeUntypedShadowForBody(graph: ShadowGraph, bodyLocation: ShadowGraph.Location) -> any Shadow {
		Body.makeUntypedShadow(graph: graph, location: bodyLocation)
	}
}
