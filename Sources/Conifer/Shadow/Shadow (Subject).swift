// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

extension Shadow {
	
	/// The component represented by `self`.
	///
	/// The component is first rendered if needed.
	public var subject: Subject {
		get async throws {
			try await graph.renderIfNeededComponent(at: location) as! Subject
		}
	}
	
	/// Accesses the subject.
	
}
