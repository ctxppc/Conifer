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
	
}
