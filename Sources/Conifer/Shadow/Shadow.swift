// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit

/// A view into a component and its contents.
///
/// Unlike shadow graphs, foundational components do not appear in shadows, i.e., `Subject` does not conform to `FoundationalComponent`.
@dynamicMemberLookup
public struct Shadow<Subject : Component> : ShadowProtocol {
	
	// See protocol.
	let graph: ShadowGraph
	
	// See protocol.
	let location: Location
	
	/// The component represented by `self`.
	let subject: Subject
	
	/// Accesses the subject.
	public subscript <Value>(dynamicMember keyPath: KeyPath<Subject, Value>) -> Value {
		subject[keyPath: keyPath]	// TODO: What about dynamic properties?
	}
	
}

extension Shadow {
	
	/// Creates a shadow of `subject`.
	///
	/// This initialiser creates a new shadow graph with `subject` as the root.
	///
	/// - Requires: `subject` is not a foundational component.
	///
	/// - Parameter subject: The component.
	public init(of subject: Subject) {
		precondition(!(subject is any FoundationalComponent), "\(subject) is a foundational component")
		self.graph = .init(root: subject)
		self.location = .anchor
		self.subject = subject
	}
	
	/// Creates a typed shadow from given untyped shadow.
	///
	/// - Parameter shadow: The untyped shadow.
	///
	/// - Returns: `nil` if the component represented by `shadow` isn't of type `Subject`.
	public init?(_ shadow: UntypedShadow) async throws {
		
		self.graph = shadow.graph
		self.location = shadow.location
		
		guard let subject = try await graph[location] as? Subject else { return nil }
		self.subject = subject
		
	}
	
}

extension Shadow where Subject.Body == Never {
	
	/// Terminates the program.
	public var body: Shadow<Subject.Body> {
		get async throws {
			try await subject.body
		}
	}
	
}
