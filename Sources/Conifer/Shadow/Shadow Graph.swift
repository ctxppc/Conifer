// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

/// A tree structure of rendered components and other types of elements.
///
/// Conifer clients do not create or directly interact with `ShadowGraph`s, except possibly for comparing graph identity with `===`. All other interactions happen via `Shadow`s.
///
/// ## Implementation Notes
/// Each node in a shadow graph can contain any number of elements but at most one per type. Each node contains at least an element of type `any Component`, representing the rendered component. The existential type ensures that no two components can occupy the same node. Although nothing prevents one from assigning a component of concrete type (e.g., an `Either`), `ShadowChildren` does not traverse or return those types of components.
///
/// A node containing children has an associated `ShadowChildLocations` element which points to the child nodes. This element is computed and stored when the component's children are rendered.
///
/// Foundational components (such as `Either`) appear as elements of a shadow graph but do not appear in shadows (`Shadow` values). This is the crucial difference between *components in a shadow graph* and *shadows* over components in the shadow graph: not every component in a shadow graph is represented by a shadow, but every shadow represents a component in a shadow graph.
public actor ShadowGraph {
	
	/// Creates a shadow graph with given root component.
	init(root: some Component) async throws {
		try await render(root, at: .anchor)
	}
	
	/// The shadow elements, keyed by location relative to the root component.
	///
	/// - Invariant: `elements[.init(location: .anchor, type: (any Component).self)]` is not `nil`. That is, `elements` stores at least a rendered root component.
	/// - Invariant: Each dynamic property in each rendered component in the graph, i.e., each element of type `any Component` in `elements`, is prepared.
	/// - Invariant: For every location named in `elements`, there is at least an element of type `any Component`. Stated differently, `elements` only stores elements for rendered components.
	private var elements = [ElementKey : Any]()
	private struct ElementKey : Hashable {
		
		/// Creates a key for an element of a given (concrete or existential) type at a given location in a graph.
		init<T>(location: ShadowLocation, type: T.Type) {
			self.location = location
			self.type = .init(type)
		}
		
		/// The location of the element in the graph.
		let location: ShadowLocation
		
		/// The type of the element that identifies the kind of associated element.
		///
		/// The type is either a concrete or existential type.
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
	func element<Element : Sendable>(ofType type: Element.Type = Element.self, at location: ShadowLocation) -> Element? {
		if let element = elements[.init(location: location, type: type)] {
			return (element as! Element)
		} else {
			return nil
		}
	}
	
	/// Assigns, replaces, or removes the element of its type at a given location in the graph.
	///
	/// `type` can be either a concrete or existential type. Concrete and existential types are never equal; the same type must be provided to `element(ofType:at:)` to retrieve the same element. It's for example possible to simultaneously assign a `String` element using the `Any` type and another using the `String` type at the same location.
	///
	/// - Parameters:
	///   - element: The new element, or `nil` to remove it.
	///   - type: The element's type. The default value is the element's concrete type, which is sufficient unless an existential type is desired.
	///   - location: The location of the element in `self`.
	func update<Element : Sendable>(_ element: Element?, ofType type: Element.Type = Element.self, at location: ShadowLocation) {
		elements[.init(location: location, type: type)] = element
	}
	
	/// Assigns, replaces, or removes the associated element of its type using a given update function.
	///
	/// `type` can be either a concrete or existential type. Concrete and existential types are never equal; the same type must be provided to `element(ofType:)` to retrieve the same element. It's for example possible to simultaneously assign a `String` element using the `Any` type and another using the `String` type at the same location.
	///
	/// - Parameters:
	///   - type: The element's type.
	///   - update: A function that accepts the current element of type `type` (or `nil` if `self` has no such element) and produces the new element (or `nil` if there should be no such element).
	///   - location: The location of the element in `self`.
	public func update<Element : Sendable, Failure>(
		_ type:			Element.Type,
		with update:	sending (Element?) async throws(Failure) -> Element?,
		at location:	ShadowLocation
	) async throws(Failure) {
		self.update(try await update(element(ofType: type, at: location)), ofType: type, at: location)
	}
	
}
