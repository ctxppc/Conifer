// Conifer © 2019–2023 Constantino Tsarouhas

protocol ShadowProtocol : Sendable {
	
	/// The graph backing `self`.
	var graph: ShadowGraph { get }
	
	/// The location of the subject relative to the root component in `graph`.
	var location: Location { get }
	
}

extension ShadowProtocol {
	
	/// Accesses a subcomponent.
	///
	/// - Invariant: `childLocation` is a valid location.
	subscript (childLocation: Location) -> UntypedShadow {
		.init(graph: graph, location: location[childLocation])
	}
	
	/// The parent component, or `nil` if `self` is a root component.
	///
	/// - Invariant: `parent` is not a foundational component.
	public var parent: UntypedShadow? {
		get async throws {
			for location in sequence(first: location, next: \.parent) {
				if !(try await graph[location] is any FoundationalComponent) {
					return .init(graph: graph, location: location)
				}
			}
			return nil
		}
	}
	
	/// The subject's children.
	///
	/// - Invariant: No component in `body` is a foundational component.
	public var body: _ShadowBody {	// TODO: Replace by `some AsyncSequence<UntypedShadow>` when AsyncSequence gets a primary associated type.
		.init(parentShadow: self)
	}
	
}
