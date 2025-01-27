// Conifer © 2019–2025 Constantino Tsarouhas

/// An ordered collection of locations of direct children of an associated component in the shadow graph.
///
/// Only components whose children have been rendered have an associated `ShadowChildLocations` collection.
struct ShadowChildLocations : Sendable {
	
	/// Creates an ordered collection of locations of a component's direct children.
	///
	/// - Requires: `location` is sorted.
	init(_ locations: [ShadowGraph.Location]) {
		self.locations = locations
	}
	
	/// The locations of the children of the associated component.
	///
	/// - Invariant: `location` is sorted.
	private var locations: [ShadowGraph.Location]
	
	/// Adds given location to `self`.
	///
	/// - Requires: `location` is not in `self`.
	/// - Requires: If `self` is nonempty, there is a location in `self` that is a direct sibling of `location`.
	mutating func add(_ location: ShadowGraph.Location) {
		if let last = locations.last, location > last {
			locations.append(location)
		} else {
			let index = locations.firstIndex(where: { $0 > location }) ?? locations.endIndex
			locations.insert(location, at: index)
		}
	}
	
}

extension ShadowChildLocations : RandomAccessCollection {
	var startIndex: Int { locations.startIndex }
	var endIndex: Int { locations.endIndex }
	subscript (position: Int) -> ShadowGraph.Location { locations[position] }
	subscript (bounds: Range<Int>) -> ArraySlice<ShadowGraph.Location> { locations[bounds] }
}
