// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

extension Shadow {
	
	/// The shadow of the nearest non-foundational ancestor component, or `nil` if `self` is a root component.
	///
	/// - Invariant: `parent` is not a foundational component.
	public var parent: (any Shadow)? {
		get async {
			// Sequence.map and .compactMap do not support await (yet) so we use a conventional loop.
			for location in sequence(first: location, next: \.parent) {
				let subjectType = await graph[location].subjectType !! "Expected known subject type for parent at \(location)"
				if !(subjectType is any FoundationalComponent.Type) {
					return subjectType.makeUntypedShadow(graph: graph, location: location)
				}
			}
			return nil
		}
	}
	
	/// The shadow of the nearest ancestor component, or `nil` if `self` is a root component.
	///
	/// The parent may be a foundational component. For the nearest non-foundational component, use `parent` instead.
	var actualParent: (any Shadow)? {
		get async {
			guard let parentLocation = location.parent else { return nil }
			let subjectType = await graph[parentLocation].subjectType !! "Expected known subject type for parent at \(location)"
			return subjectType.makeUntypedShadow(graph: graph, location: parentLocation)
		}
	}
	
	/// Returns the children of `self`, i.e., shadows over the non-foundational components that are direct descendants of `subject`.
	///
	/// - Requires: Each child is typed `type`.
	/// - Requires: `Child` conforms to `Shadow` or is an existential `Shadow` type. (This constraint cannot be formalised as of writing; existential types cannot conform to protocols yet.)
	/// - Invariant: No component in `children` is a foundational component.
	public func children<Child>(ofType type: Child.Type) -> some AsyncSequence<Child, any Error> {
		ShadowChildren(parent: self)
	}
	
}
