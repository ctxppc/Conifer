// Conifer © 2019–2025 Constantino Tsarouhas

extension Shadow {
	
	/// The component represented by `self`.
	public var subject: Subject {
		get async throws {
			let raw = try await withGraph { graph in
				try await cached(in: \.subject) {
					TODO.unimplemented
				}
			}
			guard let subject = raw as? Subject else {
				preconditionFailure("Expected subject of type \(Subject.self); got \(type(of: raw)) instead")
			}
			return subject
		}
	}
	
	/// Accesses the subject.
	public subscript <Value>(dynamicMember keyPath: KeyPath<Subject, Value>) -> Value {
		get async throws {
			try await subject[keyPath: keyPath]
		}
	}
	
}


extension ShadowSnapshot {
	
	/// The subject, or `nil` if not rendered or valid.
	var subject: (any Component)? {
		get { self[\.subject] }
		set { self[\.subject] = newValue }
	}
	
}
