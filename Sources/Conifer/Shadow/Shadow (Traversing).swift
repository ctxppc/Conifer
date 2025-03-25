// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

extension Shadow {
	
	/// The shadow of the nearest non-foundational ancestor component, or `nil` if `self` is a root component.
	///
	/// - Invariant: `parent` is not a foundational component.
	public var parent: (any Shadow)? {
		get async throws {
			// Sequence.map and .compactMap do not support await (yet) so we use a conventional loop.
			for location in sequence(first: location, next: \.parent) {
				let shadow = try await graph.shadow(at: location)
				if !(shadow.subjectType is any FoundationalComponent.Type) {
					return shadow
				}
			}
			return nil
		}
	}
	
	/// The shadow of the nearest ancestor component, or `nil` if `self` is a root component.
	///
	/// The parent may be a foundational component. For the nearest non-foundational ancestor component, use `parent` instead.
	var directParent: (any Shadow)? {
		get async throws {
			guard let parentLocation = location.parent else { return nil }
			return try await graph.shadow(at: parentLocation)
		}
	}
	
	/// Returns the nearest non-foundational descendants of `self`, i.e., shadows over the non-foundational components that are direct descendants of `subject`.
	///
	/// The returned sequence is unconstrained in the type of shadow. To constrain the type to a known fixed shadow type, use `children(ofType:)` instead.
	///
	/// - Postcondition: No component in the returned sequence is a foundational component.
	public func children() -> some AsyncSequence<any Shadow, any Error> {
		ShadowChildren(parent: self)
	}
	
	/// Returns the nearest non-foundational descendants of `self`, i.e., shadows over the non-foundational components that are direct descendants of `subject`.
	///
	/// - Requires: Each child is typed `type`.
	/// - Requires: `Child` conforms to `Shadow` or is an existential `Shadow` type. (This constraint cannot be formalised as of writing; existential types cannot conform to protocols yet.)
	/// - Postcondition: No component in the returned sequence is a foundational component.
	public func children<Child>(ofType type: Child.Type) -> some AsyncSequence<Child, any Error> {
		ShadowChildren(parent: self)
	}
	
	/// Returns the children of `self` as structured in the graph.
	///
	/// The children may be foundational components. For the nearest non-foundational descendant components, use `children(ofType:)` instead.
	func directChildren() async throws -> some Sequence<any Shadow> {
		try await childLocations
			.asyncMap(graph.shadow(at:))
	}
	
}
