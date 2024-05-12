// Conifer © 2019–2024 Constantino Tsarouhas

/// A view into a rendered component and its contents.
@dynamicMemberLookup
public protocol Shadow<Subject> : Sendable {
	
	/// Creates a shadow in a given graph over a component at given location in the graph.
	///
	/// - Parameters:
	///   - graph: The graph.
	///   - location: The subject's location in the graph.
	init(graph: ShadowGraph, location: Location)
	
	/// The graph backing `self`.
	var graph: ShadowGraph { get }
	
	/// The location of the subject relative to the root component in `graph`.
	///
	/// - Invariant: `location` refers to an already rendered component in `graph`.
	var location: Location { get }
	
	/// A component represented by an instance of`Self`.
	associatedtype Subject : Component
	
}

extension Shadow {
	
	/// The component represented by `self`.
	public var subject: Subject {
		get async throws {
			try await graph[location] as! Subject
		}
	}
	
	/// The shadow of the nearest non-foundational ancestor component, or `nil` if `self` is a root component.
	///
	/// - Invariant: `parent` is not a foundational component.
	public var parent: (any Shadow)? {
		get async {
			// Sequence.map and .compactMap do not support await (yet) so we use a conventional loop.
			for location in sequence(first: location, next: \.parent) {
				let subject = await graph[prerendered: location]
				if !(subject is any FoundationalComponent) {
					return subject.makeUntypedShadow(graph: graph, location: location)
				}
			}
			return nil
		}
	}
	
	/// Returns the subject's children.
	///
	/// - Invariant: No component in `children` is a foundational component.
	public func children<T>(ofType type: T.Type) -> ShadowChildren<Self, T> {
		.init(parentShadow: self)
	}
	
	/// Returns the associated element of a given type.
	public func element<Element : Sendable>(ofType type: Element.Type) async -> Element? {
		await graph.element(ofType: type, at: location)
	}
	
	/// Assigns or replaces the associated element of its type.
	///
	/// `type` can be either a concrete or existential type. Concrete and existential types are never equal; the same type must be provided to `element(ofType:)` to retrieve the same element. It's for example possible to simultaneously assign a `String` element using the `Any` type and another using the `String` type at the same location.
	///
	/// - Parameters:
	///   - element: The new element.
	///   - type: The element's type. The default value is the element's concrete type, which is sufficient unless an existential type is desired.
	public func update<Element : Sendable>(_ element: Element, ofType type: Element.Type = Element.self) async {
		await graph.update(element, ofType: type, at: location)
	}
	
	/// Accesses the subject.
	public subscript <Value>(dynamicMember keyPath: KeyPath<Subject, Value>) -> Value {
		get async throws {
			try await subject[keyPath: keyPath]
		}
	}
	
}

/// Creates a shadow over `subject`.
///
/// This function creates a new shadow graph rooted in `subject`.
///
/// - Requires: `subject` is not a foundational component.
///
/// - Parameter subject: The component over which to create a shadow.
///
/// - Returns: A shadow over `subject` in a new shadow graph.
public func makeShadow<C : Component>(over subject: C) async throws -> some Shadow<C> {
	precondition(!(subject is any FoundationalComponent), "\(subject) is a foundational component")
	return ShadowType(graph: try await .init(root: subject), location: .anchor)
}
