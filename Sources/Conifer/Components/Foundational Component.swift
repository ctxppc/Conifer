// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

/// A structural element in a component tree with no semantic meaning.
///
/// This protocol enables Conifer to treat its structural component types specially. This power is not afforded to Conifer clients which get a simplified API instead.
protocol FoundationalComponent : Component where Body == Never {
	
	/// Returns the locations relative to `self` for each child of `self`.
	///
	/// Locations can be used as stable identifiers across renderings.
	///
	/// - Postcondition: For each returned location `l`, `l.parent == .anchor`.
	///
	/// - Warning: Accessing `shadow`'s descendants may cause an infinite loop.
	///
	/// - Parameter shadow: The shadow over `self`.
	///
	/// - Returns: The locations relative to `self` for each child of `self`.
	func childLocations(for shadow: some Shadow<Self>) async throws -> [ShadowGraph.Location]
	
	/// Returns the type of the child of `self` at a given location relative to `self`.
	///
	/// This method uses static type information where possible and avoids computing the child.
	///
	/// - Warning: Accessing `shadow`'s descendants may cause an infinite loop.
	///
	/// - Requires: `location` is an element of the array returned by `childLocations(for:)`.
	///
	/// - Parameters:
	///    - location: The location relative to `self` of the requested child.
	///    - shadow: The shadow over `self`.
	///
	/// - Returns: The type of `child(at: location, for: shadow)`.
	func typeOfChild(at location: ShadowGraph.Location, for shadow: some Shadow<Self>) async throws -> any Component.Type
	
	/// Returns the child of `self` at a given location relative to `self`.
	///
	/// - Warning: Accessing `shadow`'s descendants may cause an infinite loop.
	///
	/// - Requires: `location` is an element of the array returned by `childLocations(for:)`.
	///
	/// - Parameters:
	///    - location: The location relative to `self` of the requested child.
	///    - shadow: The shadow over `self`.
	///
	/// - Returns: The child at `shadow.location[location]` in `shadow.graph`.
	func child(at location: ShadowGraph.Location, for shadow: some Shadow<Self>) async throws -> any Component
	
	/// Performs additional post-rendering actions on the shadow of `self`.
	///
	/// `shadow` is a shadow over a foundational component and hence must not be passed to Conifer clients.
	///
	/// This method may trigger additional renderings during its execution if `shadow`'s descendants are accessed.
	///
	/// The default implementation does nothing.
	func finalise(_ shadow: some Shadow<Self>) async throws
	
}

extension FoundationalComponent {
	
	// See protocol.
	func finalise(_ shadow: some Shadow<Self>) async throws {}
	
	/// Returns the type of the child of `self` at a given location relative to `self`.
	///
	/// This method uses static type information where possible and avoids computing the child.
	///
	/// - Warning: Accessing `shadow`'s descendants may cause an infinite loop.
	///
	/// - Requires: `location` is an element of the array returned by `childLocations(for:)`.
	///
	/// - Parameters:
	///    - location: The *absolute* location of the requested child.
	///    - graph: The shadow graph.
	///
	/// - Returns: The type of `child(at: location, for: shadow)`.
	func typeOfChild(at absoluteLocation: ShadowGraph.Location, in graph: ShadowGraph) async throws -> any Component.Type {
		let direction = with(absoluteLocation) { $0.parent = nil }
		let parentLocation = absoluteLocation.parent !! "Expected parent location of child"
		return try await typeOfChild(at: direction, for: Self.makeShadow(graph: graph, location: parentLocation))
	}
	
	/// Terminates the program with an error message stating that `self` has no body.
	var hasNoBody: Never {
		fatalError("\(self) has no body")
	}
	
}
