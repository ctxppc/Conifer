// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit
import SortedCollections

/// A tree structure of rendered components.
///
/// Foundational components appear in a shadow graph but do not appear in shadows.
actor ShadowGraph {
	
	/// Creates a shadow graph with given root component.
	init(root: some Component) {
		self.root = root
		self.componentsByLocation = [.anchor: root]
	}
	
	/// The root component.
	let root: any Component
	
	/// Accesses a component in the shadow graph at a given location relative to the root component.
	///
	/// - Requires: `location` refers to a (possibly not-yet-rendered) component whose parent is already rendered.
	subscript (location: Location) -> any Component {
		get async throws {
			
			if let component = componentsByLocation[location] {
				return component
			}
			
			try await renderChildren(ofComponentAt: location.parent !! "Expected parent of component at \(location) to be already rendered")
			return self[prerendered: location]
			
		}
	}
	
	/// Accesses an already rendered component in the shadow graph at a given location relative to the root component.
	///
	/// - Requires: `location` refers to an already rendered component.
	subscript (prerendered location: Location) -> any Component {
		componentsByLocation[location] !! "Expected component at \(location) to be already rendered"
	}
	
	/// The rendered components, keyed by location relative to the root component and ordered in pre-order.
	///
	/// - Invariant: `componentsByLocation[.self]` is not `nil`.
	private var componentsByLocation: SortedDictionary<Location, any Component>
	
	/// Renders if needed the children of the component at `parentLocation`.
	///
	/// - Postcondition: `childLocationsByLocation[parentLocation]` is not `nil`.
	/// - Postcondition: For each `location` in `childLocationsByLocation[parentLocation]`, `componentsByLocation[location]` is not `nil`.
	private func renderChildren(ofComponentAt parentLocation: Location) async throws {
		_ = try await childLocations(ofComponentAt: parentLocation)
	}
	
	/// Returns the locations of the children of the component at `parentLocation`, rendering them if needed.
	///
	/// - Requires: `parentLocation` is a location to a valid (possibly not-yet-rendered) component in `self`.
	/// - Postcondition: `childLocationsByLocation[parentLocation]` is equal to this method's result.
	/// - Postcondition: For each `location` in the returned array, `componentsByLocation[location]` is not `nil`.
	func childLocations(ofComponentAt parentLocation: Location) async throws -> ShadowChildLocations {
		
		if let childLocations: ShadowChildLocations = self[parentLocation] {
			return childLocations
		}
		
		// TODO: Prepare dynamic properties.
		
		let parent = try await self[parentLocation]
		let childLocations: ShadowChildLocations
		if let parent = parent as? any FoundationalComponent {
			
			let labelledChildren = try await parent.labelledChildren(for: self).map { location, child in
				(parentLocation[location], child)
			}
			
			for (childLocation, child) in labelledChildren {
				componentsByLocation.updateValue(child, forKey: childLocation)
			}
			
			childLocations = .init(labelledChildren.map { $0.0 })
			
		} else {
			let childLocation = parentLocation[.body]
			componentsByLocation.updateValue(try await parent.body, forKey: childLocation)
			childLocations = .init([childLocation])
		}
		
		self[parentLocation] = childLocations
		return childLocations
		
	}
	
	/// Accesses the element of type `Element` associated with the component at given location.
	subscript <Element : Sendable>(location: Location) -> Element? {
		get {
			if let element = elements[.init(location: location, type: Element.self)] {
				return (element as! Element)
			} else {
				return nil
			}
		}
		set { elements[.init(location: location, type: Element.self)] = newValue }
	}
	
	/// Accesses the element of type `Element` associated with the component at given location.
	subscript <Element : Sendable>(location: Location, default d: @autoclosure () -> Element) -> Element {
		get { self[location] ?? d() }
		set { self[location] = newValue }
	}
	
	/// Updates the element of type `Element` associated with the component at given location.
	func updateElement<Element : Sendable>(_ element: Element, at location: Location) {
		self[location] = element
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
	
	/// Updates dynamic properties of components in `self` using a given function.
	///
	/// - Parameter update: A function that updates dynamic properties.
	func performUpdates(_ update: () -> ()) {
		update()
	}
	
}
