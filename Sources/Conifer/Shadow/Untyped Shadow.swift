// Conifer © 2019–2024 Constantino Tsarouhas

public struct UntypedShadow : ShadowProtocol {
	
	// TODO: Delete type when it can be expressed as Shadow<any Component>, when Swift supports adding conformances to existentials.
	
	// See protocol.
	let graph: ShadowGraph
	
	// See protocol.
	let location: Location
	
	/// The component represented by `self`.
	var subject: any Component {
		get async throws {
			try await graph[location]
		}
	}
	
}

extension UntypedShadow {
	
	/// Creates an untyped shadow from given typed shadow.
	public init<C>(_ shadow: Shadow<C>) {
		self.graph = shadow.graph
		self.location = shadow.location
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
	
	/// Performs a given action on `self`.
	public func perform<A : Action>(_ action: A) async throws -> A.Result {
		try await action.perform(on: self)
	}
	
	/// An action that can be taken on an untyped shadow.
	///
	/// Shadow actions are parametrised over a subject type and can therefore not be expressed as a simple function, since Swift does not support generic function values. Shadow actions are therefore expressed as concrete types conforming to the `ShadowAction` protocol.
	public protocol Action {
		
		/// Performs the action on given shadow.
		func perform<Subject>(on shadow: Shadow<Subject>) async throws -> Result
		
		/// The result of the action.
		associatedtype Result
		
	}
	
}

extension UntypedShadow.Action {
	
	/// Performs the action on a given untyped shadow.
	///
	/// - Parameter shadown: The shadow on which to perform the action.
	///
	/// - Returns: The result of the action.
	fileprivate func perform(on shadow: UntypedShadow) async throws -> Result {
		try await perform(subject: shadow.subject, graph: shadow.graph, location: shadow.location)
	}
	
	/// Performs the action on the shadow specified by a given subject, graph, and graph location.
	///
	/// - Parameters:
	///   - subject: The subject on which to perform the action. The argument is only used by the Swift runtime to open an `any Component` existential and create an appropriate `Shadow` type.
	///   - graph: The shadow graph on which to perform the action.
	///   - location: The location of the shadow on which to perform the action.
	///
	/// - Returns: The result of the action.
	private func perform<Subject : Component>(subject: Subject, graph: ShadowGraph, location: Location) async throws -> Result {
		try await perform(on: Shadow<Subject>(graph: graph, location: location))
	}
	
}
