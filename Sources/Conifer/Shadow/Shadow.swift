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
	var subject: Subject {
		get async throws {
			try await graph[location] as! Subject
		}
	}
	
	/// Accesses the subject.
	public subscript <Value>(dynamicMember keyPath: KeyPath<Subject, Value>) -> Value {
		get async throws {
			try await subject[keyPath: keyPath]
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
	
	/// The shadow of the nearest non-foundational ancestor component, or `nil` if `self` is a root component.
	///
	/// - Invariant: `parent` is not a foundational component.
	public var parent: UntypedShadow? {
		get async { await (self as ShadowProtocol).parent }
	}
	
	/// The subject's children.
	///
	/// - Invariant: No component in `children` is a foundational component.
	public var children: ShadowChildren {	// TODO: Replace by `some AsyncSequence<UntypedShadow>` when AsyncSequence gets a primary associated type.
		(self as ShadowProtocol).children
	}
	
	/// Returns the associated element of a given type.
	public func element<Element : Sendable>(ofType type: Element.Type) async -> Element? {
		await (self as ShadowProtocol).element(ofType: type)
	}
	
	/// Updates the associated element of type `Element` using a given function.
	///
	/// - Parameter d: The default value if the shadow doesn't have an associated element of type `Element`.
	/// - Parameter update: A function that updates a given element.
	///
	/// - Returns: The value returned by `update`.
	public func update<Element : Sendable, Result>(
		default d:	@autoclosure () async throws -> Element,
		_ update:	(inout Element) async throws -> Result
	) async rethrows -> Result {
		try await graph.update(at: location, default: try await d(), update)
	}
	
}
