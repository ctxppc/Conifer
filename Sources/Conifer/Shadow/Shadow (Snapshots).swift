// Conifer © 2019–2025 Constantino Tsarouhas

extension Shadow {
	
	/// A sequence of snapshots of `self`.
	///
	/// The sequence drops snapshots that are not consumed before the next snapshot is observed.
	///
	/// The sequence strongly references the shadow graph. Since the graph continues to exist at least as long as the sequence exists, the sequence does not finish.
	public var snapshots: some AsyncSequence<ShadowSnapshot, Never> {
		AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
			Task { [graph] in
				let subscription = await graph.observeShadow(at: location) { snapshot in
					continuation.yield(snapshot)
				}
				continuation.onTermination = { _ in
					Task {
						await graph.stopObserving(subscription: subscription)
					}
				}
			}
		}
	}
	
}
