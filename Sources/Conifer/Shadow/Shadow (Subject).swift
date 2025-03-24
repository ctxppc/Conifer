// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

extension Shadow {
	
	/// The component represented by `self`.
	public var subject: Subject {
		get async throws {
			let subject = try await withGraph { graph in
				try await cached(in: \.subject) {
					guard let parent = await actualParent else { preconditionFailure("The root component cannot be rerendered.") }
					let parentComponent = try await parent.subject
					let raw = if let parentComponent = parentComponent as? any FoundationalComponent {
						try await renderUntypedSubject(childOf: parentComponent, parentLocation: parent.location, in: graph)
					} else {
						try await renderUntypedSubject(childOf: parentComponent, parentLocation: parent.location)
					}
					var subject = raw as? Subject !! "Expected subject of type \(Subject.self); got \(type(of: subject)) instead"
					try await subject.updateDynamicProperties(for: self)
					return subject
				}
			}
			return subject as? Subject !! "Expected subject of type \(Subject.self); got \(type(of: subject)) instead"
		}
	}
	
	/// Renders and returns the subject.
	///
	/// - Requires: `graph === self.graph`. The parameter only exists to pass isolation.
	///
	/// - Parameters:
	///    - parentComponent: The subject's parent component.
	///    - parentLocation: The (absolute) location of the parent.
	///    - graph: The shadow graph.
	///
	/// - Returns: The subject.
	private func renderUntypedSubject(
		childOf parentComponent:	some FoundationalComponent,
		parentLocation:				Location,
		in graph:					ShadowGraph
	) async throws -> any Component {
		let direction = with(location) { $0.parent = nil }
		let parentShadow = type(of: parentComponent).makeShadow(graph: graph, location: parentLocation)
		return try await parentComponent.child(at: direction, for: parentShadow)
	}
	
	/// Renders and returns the subject.
	///
	/// - Requires: `graph === self.graph`. The parameter only exists to pass isolation.
	///
	/// - Parameters:
	///    - parentComponent: The subject's parent component.
	///    - parentLocation: The (absolute) location of the parent.
	///    - graph: The shadow graph.
	///
	/// - Returns: The subject.
	private func renderUntypedSubject(
		childOf parentComponent:	some Component,
		parentLocation:				Location
	) async throws -> any Component {
		let direction = with(location) { $0.parent = nil }
		precondition(direction == .anchor.body, "Child of non-foundational component is at \(direction) instead of \(Location.anchor.body)")
		return try await parentComponent.body
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
		set {
			self[\.subject] = newValue
			if let newValue {
				subjectType = type(of: newValue)
			}
		}
	}
	
	/// The subject type, or `nil` if not known yet.
	///
	/// This shadow property is set once the subject is rendered. This property is not unset when the subject is invalidated. It allows the system to create shadows even after the subject is invalidated.
	var subjectType: (any Component.Type)? {
		get { self[\.subjectType] }
		set { self[\.subjectType] = newValue }
	}
	
}
