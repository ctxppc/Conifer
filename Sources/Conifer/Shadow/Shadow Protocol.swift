// Conifer © 2019–2024 Constantino Tsarouhas

/// A view into a rendered component and its contents.
///
/// This protocol is not exposed to Conifer clients, who directly interact with `Shadow` and `UntypedShadow` values instead. This protocol is to be replaced by `Shadow` when `UntypedShadow` can be expressed as `Shadow<any Component>`.
protocol ShadowProtocol : Sendable {
	
	// TODO: Delete protocol when UntypedShadow can be expressed as Shadow<any Component>.
	
	/// The graph backing `self`.
	var graph: ShadowGraph { get }
	
	/// The location of the subject relative to the root component in `graph`.
	///
	/// - Invariant: `location` refers to an already rendered component in `graph`.
	var location: Location { get }
	
}

extension ShadowProtocol {
	
	/// The shadow of the nearest non-foundational ancestor component, or `nil` if `self` is a root component.
	///
	/// - Invariant: `parent` is not a foundational component.
	public var parent: UntypedShadow? {
		get async {
			// Sequence.map and .compactMap do not support await (yet) so we use a conventional loop.
			for location in sequence(first: location, next: \.parent) {
				let subject = await graph[prerendered: location]
				if !(subject is any FoundationalComponent) {
					return .init(graph: graph, location: location)
				}
			}
			return nil
		}
	}
	
	/// The subject's children.
	///
	/// - Invariant: No component in `children` is a foundational component.
	public var children: ShadowChildren {	// TODO: Replace by `some AsyncSequence<UntypedShadow>` when AsyncSequence gets a primary associated type.
		.init(parentShadow: self)
	}
	
	/// Accesses a subcomponent.
	///
	/// - Invariant: `childLocation` refers to a (possibly not yet rendered) component relative to `self`'s subject.
	subscript (childLocation: Location) -> UntypedShadow {
		let graphLocation = location[childLocation]
		return .init(graph: graph, location: graphLocation)
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
	func update<Element : Sendable>(_ element: Element, ofType type: Element.Type = Element.self) async {
		await graph.update(element, ofType: type, at: location)
	}
	
}
