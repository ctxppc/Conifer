// Conifer © 2019–2023 Constantino Tsarouhas

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
		self.childLocationsByLocation = [:]
	}
	
	/// The root component.
	let root: any Component
	
	/// The rendered components, keyed by location relative to the root component and ordered in pre-order.
	///
	/// - Invariant: `componentsByLocation[.self]` is not `nil`.
	private var componentsByLocation: SortedDictionary<Location, any Component>
	
	/// The locations of rendered child components, keyed by location of parent component.
	private var childLocationsByLocation: [Location : [Location]]
	
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
	
	/// Renders if needed the children of the component at `parentLocation`.
	///
	/// - Postcondition: `childLocationsByLocation[parentLocation]` is not `nil`.
	/// - Postcondition: For each `location` in `childLocationsByLocation[parentLocation]`, `componentsByLocation[location]` is not `nil`.
	private func renderChildren(ofComponentAt parentLocation: Location) async throws {
		_ = try await childLocations(ofComponentAt: parentLocation)
	}
	
	/// Returns the locations of the children of the component at `parentLocation`, rendering them if needed.
	///
	/// - Postcondition: `childLocationsByLocation[parentLocation]` is equal to this method's result.
	/// - Postcondition: For each `location` in the returned array, `componentsByLocation[location]` is not `nil`.
	func childLocations(ofComponentAt parentLocation: Location) async throws -> [Location] {
		
		if let childLocations = childLocationsByLocation[parentLocation] {
			return childLocations
		}
		
		let parent = try await self[parentLocation]
		let childLocations: [Location]
		if let parent = parent as? any FoundationalComponent {
			
			let labelledChildren = try await parent.labelledChildren(for: self).map { location, child in
				(parentLocation[location], child)
			}
			
			for (childLocation, child) in labelledChildren {
				componentsByLocation.updateValue(child, forKey: childLocation)
			}
			
			childLocations = labelledChildren.map { $0.0 }
			
		} else {
			let childLocation = parentLocation[.body]
			componentsByLocation.updateValue(try await parent.body, forKey: childLocation)
			childLocations = [childLocation]
		}
		
		childLocationsByLocation[parentLocation] = childLocations
		return childLocations
		
	}
	
}
