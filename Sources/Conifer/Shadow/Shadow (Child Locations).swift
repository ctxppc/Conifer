// Conifer © 2019–2025 Constantino Tsarouhas

extension Shadow {
	
	/// The (absolute) locations of the children of `subject` in the graph.
	var childLocations: [ShadowGraph.Location] {
		get async throws {
			try await withGraph { graph in
				try await cached(in: \.childLocations) {
					if let subject = try await subject as? any FoundationalComponent {
						return try await childLocations(of: subject)
					} else {
						return [location[.anchor.body]]
					}
				}
			}
		}
	}
	
	/// Determines the (absolute) child locations of the subject.
	///
	/// - Requires: `subject` is the same as `self.subject`. The parameter only exists to open the existential.
	///
	/// - Parameter subject: The subject whose child locations to determine.
	///
	/// - Returns: The (absolute) child locations of `subject`.
	private func childLocations<Subject : FoundationalComponent>(of subject: Subject) async throws -> [Location] {
		try await subject
			.childLocations(for: Subject.makeShadow(graph: graph, location: location))
			.map { location[$0] }
	}
	
}

extension ShadowSnapshot {
	
	/// The (absolute) locations of the children of `subject` in the graph, or `nil` if not determined yet.
	var childLocations: [ShadowGraph.Location]? {
		get { self[\.childLocations] }
		set { self[\.childLocations] = newValue }
	}
	
}
