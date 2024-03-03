// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit
import SortedCollections

/// A tree structure of rendered components.
///
/// Foundational components appear in a shadow graph but do not appear in shadows (instances of `Shadow` and `UntypedShadow`).
///
/// The shadow graph lazily renders components as they are requested. When a component is first rendered, it is instantiated, its dynamic properties are prepared, and it is added to the graph. A rendered component's children may not be rendered but the shadow graph can readily do so since the parent's dynamic properties are ready for use.
actor ShadowGraph {
	
	/// Creates a shadow graph with given root component.
	init(root: some Component) async throws {
		self.componentsByLocation = [:]
		try await render(child: root, at: .anchor)
	}
	
	/// Accesses a component in the shadow graph at a given location relative to the root component.
	///
	/// - Requires: `location` refers to a (possibly not-yet-rendered) component whose parent is already rendered.
	subscript (location: Location) -> any Component {
		get async throws {
			
			if let component = componentsByLocation[location] {
				return component
			}
			
			try await renderChildren(ofComponentAt: location.parent !! "Expected root component to be already rendered")
			return self[prerendered: location]
			
		}
	}
	
	/// Accesses an already rendered component in the shadow graph at a given location relative to the root component.
	///
	/// - Requires: `location` refers to an already rendered component in `self`.
	subscript (prerendered location: Location) -> any Component {
		componentsByLocation[location] !! "Expected component at \(location) to be already rendered"
	}
	
	/// The rendered components, keyed by location relative to the root component and ordered in pre-order.
	///
	/// - Invariant: `componentsByLocation[.anchor]` is not `nil`.
	/// - Invariant: Each dynamic property in each component in `componentsByLocation` is prepared.
	var componentsByLocation: SortedDictionary<Location, any Component>
	
	/// Accesses the element of a given type associated with the component at a given location.
	///
	/// - Requires: `location` refers to an already rendered component in `self`.
	subscript <Element : Sendable>(ofType type: Element.Type = Element.self, location: Location) -> Element? {
		get {
			if let element = elements[.init(location: location, type: Element.self)] {
				return (element as! Element)
			} else {
				return nil
			}
		}
		set { elements[.init(location: location, type: Element.self)] = newValue }
	}
	
	/// Updates the element of type `Element` associated with the component at a given location using a given function.
	///
	/// - Parameter location: The location of the component in `self`.
	/// - Parameter d: The default value if the shadow doesn't have an associated element of type `Element`.
	/// - Parameter update: A function that updates a given element.
	///
	/// - Returns: The value returned by `update`.
	///
	/// - Requires: `location` refers to an already rendered component in `self`.
	func update<Element : Sendable, Result>(
		at location:	Location,
		default d:		@autoclosure () async throws -> Element,
		_ update:		(inout Element) async throws -> Result
	) async rethrows -> Result {
		var element = if let e = self[ofType: Element.self, location] {
			e
		} else {
			try await d()
		}	// Nil-coalescing doesn't work when default argument has effects
		let result = try await update(&element)
		self[location] = element
		return result
	}
	
	/// The shadow elements.
	private var elements = [ShadowElementKey : Any]()
	private struct ShadowElementKey : Hashable {
		
		init(location: Location, type: any Sendable.Type) {
			self.location = location
			self.type = .init(type)
		}
		
		let location: Location
		let type: ObjectIdentifier
		
	}
	
}
