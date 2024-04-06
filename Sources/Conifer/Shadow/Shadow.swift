// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit

/// A view into a component and its contents.
///
/// Unlike shadow graphs, foundational components do not appear in shadows, i.e., `Subject` does not conform to `FoundationalComponent`.
public struct Shadow<Subject : Component> : ShadowProtocol {
	
	// See protocol.
	let graph: ShadowGraph
	
	// See protocol.
	let location: Location
	
	/// The component represented by `self`.
	public var subject: Subject {
		get async throws {
			try await graph[location] as! Subject
		}
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
	public init(of subject: Subject) async throws {
		precondition(!(subject is any FoundationalComponent), "\(subject) is a foundational component")
		self.graph = try await .init(root: subject)
		self.location = .anchor
	}
	
	/// Creates a typed shadow from given untyped shadow.
	///
	/// - Parameter shadow: The untyped shadow.
	///
	/// - Returns: `nil` if the component represented by `shadow` isn't of type `Subject`.
	public init?(_ shadow: UntypedShadow) async throws {
		self.graph = shadow.graph
		self.location = shadow.location
		guard try await graph[location] is Subject else { return nil }
	}
	
}
