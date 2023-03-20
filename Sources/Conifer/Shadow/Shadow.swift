// Conifer © 2019–2023 Constantino Tsarouhas

import DepthKit

/// A view into a component and its contents.
///
/// Unlike shadow graphs, foundational components do not appear in shadows, i.e., `Subject` does not conform to `FoundationalComponent`.
@dynamicMemberLookup
public struct Shadow<Subject : Component> : ShadowProtocol {
	
	/// Creates a shadow of `subject`.
	public init(of subject: Subject, transformingFrom transformationSource: UntypedShadow? = nil) {
		self.graph = .init(root: subject, transformationSource: transformationSource)
		self.location = .anchor
		self.subject = subject
	}
	
	/// Creates a typed shadow from given untyped shadow.
	init?(_ shadow: UntypedShadow) async throws {
		
		self.graph = shadow.graph
		self.location = shadow.location
		
		guard let subject = try await graph[location] as? Subject else { return nil }
		self.subject = subject
		
	}
	
	// See protocol.
	let graph: ShadowGraph
	
	// See protocol.
	let location: Location
	
	/// The component represented by `self`.
	let subject: Subject
	
	/// Accesses the subject.
	public subscript <Value>(dynamicMember keyPath: KeyPath<Subject, Value>) -> Value {
		subject[keyPath: keyPath]
	}
	
}
