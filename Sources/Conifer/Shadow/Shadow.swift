// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit

/// A view into a component and its contents.
///
/// Except during some internal Conifer processes, foundational components do not appear in shadows, i.e., `Subject` does not conform to `FoundationalComponent`.
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
	
	/// The subject type.
	public typealias SubjectType = Subject
	
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
	public var parent: UntypedShadow? {	// exports private ShadowProtocol API
		get async { await (self as ShadowProtocol).parent }
	}
	
	/// The subject's children.
	///
	/// - Invariant: No component in `children` is a foundational component.
	public var children: ShadowChildren {	// TODO: Replace by `some AsyncSequence<UntypedShadow>` when AsyncSequence gets a primary associated type.
		(self as ShadowProtocol).children
	}	// exports private ShadowProtocol API
	
	/// Returns the associated element of a given type, or `nil` if no such element exists.
	///
	/// `type` can be either a concrete or existential type. Concrete and existential types are never equal; the type of the desired element must match the type provided to `update(_:ofType:)` when the element was assigned.
	///
	/// - Parameter type: The element's concrete or existential type.
	///
	/// - Returns: The associated element of type `type`.
	public func element<Element : Sendable>(ofType type: Element.Type) async -> Element? {	// exports private ShadowProtocol API
		await (self as ShadowProtocol).element(ofType: type)
	}
	
	/// Assigns or replaces the associated element of its type.
	///
	/// `type` can be either a concrete or existential type. Concrete and existential types are never equal; the same type must be provided to `element(ofType:)` to retrieve the same element. It's for example possible to simultaneously assign a `String` element using the `Any` type and another using the `String` type at the same location.
	///
	/// - Parameters:
	///   - element: The new element.
	///   - type: The element's type. The default value is the element's concrete type, which is sufficient unless an existential type is desired.
	func update<Element : Sendable>(_ element: Element, ofType type: Element.Type = Element.self) async {	// exports private ShadowProtocol API
		await (self as ShadowProtocol).update(element, ofType: type)
	}
	
}
