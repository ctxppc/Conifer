// Conifer © 2019–2023 Constantino Tsarouhas

import DepthKit
import OrderedCollections

/// A tree structure of rendered components.
///
/// Foundational elements appear in a shadow graph but do not appear in shadows.
actor ShadowGraph {
	
	/// Creates a shadow graph with given root component.
	init(root: some Component) {
		self.root = root
		self.componentsByLocation = [.anchor: root]
	}
	
	/// The root component.
	let root: any Component
	
	/// The rendered components, keyed by location relative to the root component.
	///
	/// - Invariant: `componentsByLocation[.self]` is not `nil`.
	var componentsByLocation: OrderedDictionary<Location, any Component>
	
	/// Accesses a component in the shadow graph at a given location relative to the root component.
	///
	/// - Requires: `location` is a valid location.
	subscript (location: Location) -> any Component {
		get async throws {
			
			if let component = componentsByLocation[location] {
				return component
			}
			
			try await renderChildren(ofComponentAt: location.parent)
			guard let component = componentsByLocation[location] else {
				preconditionFailure("\(location) is not a valid location relative to \(root)")
			}
			
			return component
			
		}
	}
	
	/// Renders the direct children of the component at `parentLocation`.
	///
	/// - Requires: This method hasn't been invoked with `parentLocation` before. (A future version of this method may do nothing if it is invoked a second time.)
	private func renderChildren(ofComponentAt parentLocation: Location) async throws {
		let parent = try await self[parentLocation]
		let parentIndex = componentsByLocation.index(forKey: parentLocation) !! "No index for already rendered parent"
		if let parent = parent as? any FoundationalComponent {
			for (location, child) in try await parent.labelledChildren.reversed() {
				componentsByLocation.updateValue(
									child,
					forKey:			parentLocation[location],
					insertingAt:	parentIndex + 1
				)
			}
		} else {
			componentsByLocation.updateValue(
								try await parent.body,
				forKey:			parentLocation[.body],
				insertingAt:	parentIndex + 1
			)
		}
	}
	
}
