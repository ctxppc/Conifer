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
		get async throws {
			// Sequence.map and .compactMap do not support await (yet) so we use a conventional loop.
			for location in sequence(first: location, next: \.parent) {
				let subject = await graph[prerendered: location]
				if !(subject is any FoundationalComponent) {
					return .init(graph: graph, location: location, subject: subject)
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
		get async throws {
			let graphLocation = location[childLocation]
			return .init(graph: graph, location: graphLocation, subject: try await graph[graphLocation])
		}
	}
	
	/// Returns the associated element of given type.
	public func element<Element : Sendable>(ofType _: Element.Type) async -> Element? {
		await graph[location]
	}
	
	/// Updates the associated element of given type.
	public func updateElement<Element : Sendable>(_ element: Element) async {
		await graph.updateElement(element, at: location)
	}
	
	/// Updates dynamic properties of the shadowed component, its descendants, or its ancestors using a given function.
	///
	/// - Parameter updates: A function that updates dynamic properties.
	public func performUpdates(_ updates: () -> ()) async {	// TODO: Is this a good API?
		await graph.performUpdates(updates)
	}
	
}
