// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit

/// A tree structure of rendered components and other types of elements.
///
/// Each node in a shadow graph can contain any number of elements but at most one per type. Rendered components are elements of type `any Component`. The existential type ensures that no two components can occupy the same node. Although nothing prevents one from assigning a component of concrete type (e.g., `Either<…, …>`), `ShadowChildren` does not traverse or return those types of components.
///
/// Foundational components (such as `Either`) appear as elements of a shadow graph but do not appear in shadows (`Shadow` values).
///
/// The shadow graph lazily renders components as they are requested. When a component is first rendered, it is instantiated, its dynamic properties are prepared, and it is added to the graph, simultaneously with the locations of its children. A rendered component's children may not be rendered but the shadow graph can readily do so since the parent's dynamic properties are ready for use.
public actor ShadowGraph {
	
	/// Creates a shadow graph with given root component.
	init(root: some Component) async throws {
		try await render(component: root, at: .anchor)
	}
	
	/// The shadow elements, keyed by location relative to the root component.
	///
	/// - Invariant: `elements[.init(location: .anchor, type: (any Component).self)]` is not `nil`.
	/// - Invariant: Each dynamic property in each rendered component in the graph, i.e., each element of type `any Component` in `elements`, is prepared.
	private var elements = [ElementKey : Any]()
	private struct ElementKey : Hashable {
		
		/// Creates a key for an element of a given type (concrete or existential) at a given location in a graph.
		init<T>(location: Location, type: T.Type) {
			self.location = location
			self.type = .init(type)
		}
		
		/// The location of the element in the graph.
		let location: Location
		
		/// The identifier of the type of the element.
		///
		/// The type is usually a concrete type but can also be an existential type.
		let type: ObjectIdentifier
		
	}
	
	/// Returns the element of a given type at a given location in the graph, or `nil` if no such element exists.
	///
	/// `type` can be either a concrete or existential type. Concrete and existential types are never equal; the type of the desired element must match the type provided to `update(_:ofType:at:)` when the element was assigned.
	///
	/// - Parameters:
	///   - type: The element's concrete or existential type.
	///   - location: The location of the element in `self`.
	///
	/// - Returns: The element of type `type` at `location` in `self`.
	func element<Element : Sendable>(ofType type: Element.Type = Element.self, at location: Location) -> Element? {
		if let element = elements[.init(location: location, type: type)] {
			return (element as! Element)
		} else {
			return nil
		}
	}
	
	/// Assigns or replaces the element of its type at a given location in the graph.
	///
	/// `type` can be either a concrete or existential type. Concrete and existential types are never equal; the same type must be provided to `element(ofType:at:)` to retrieve the same element. It's for example possible to simultaneously assign a `String` element using the `Any` type and another using the `String` type at the same location.
	///
	/// - Parameters:
	///   - element: The new element.
	///   - type: The element's type. The default value is the element's concrete type, which is sufficient unless an existential type is desired.
	///   - location: The location of the element in `self`.
	func update<Element : Sendable>(_ element: Element, ofType type: Element.Type = Element.self, at location: Location) {
		elements[.init(location: location, type: type)] = element
	}
	
}
