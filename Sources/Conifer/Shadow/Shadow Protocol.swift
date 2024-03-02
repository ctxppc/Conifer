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
	
	/// Accesses a subcomponent.
	///
	/// - Invariant: `childLocation` refers to a (possibly not yet rendered) component relative to `self`'s subject.
	subscript (childLocation: Location) -> UntypedShadow {
		get async throws {
			let graphLocation = location[childLocation]
			return .init(graph: graph, location: graphLocation, subject: try await graph[graphLocation])
		}
	}
	
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
	
}
