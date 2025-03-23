// Conifer © 2019–2025 Constantino Tsarouhas

extension Shadow {
	
	/// The locations of the children of `subject` in the graph.
	var childLocations: [ShadowGraph.Location] {
		get async throws {
			try await withGraph { graph in
				try await cached(in: \.childLocations) {
					TODO.unimplemented
				}
			}
		}
	}
	
}

extension ShadowSnapshot {
	
	/// The locations of the children of `subject` in the graph, or `nil` if not determined yet.
	var childLocations: [ShadowGraph.Location]? {
		get { self[\.childLocations] }
		set { self[\.childLocations] = newValue }
	}
	
}
