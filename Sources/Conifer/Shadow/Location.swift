// Conifer © 2019–2024 Constantino Tsarouhas

/// A component's location in a shadow relative to an anchor.
///
/// Locations are ordered in pre-order form: ancestors precede their descendants, siblings are ordered normally, and a component's descendants are ordered before the siblings that follow that component.
public struct Location : Hashable, @unchecked Sendable {	// AnyHashable isn't Sendable
	
	/// The location referring to the anchor.
	static let anchor = Self(directions: [])
	
	/// A location referring to the singular child.
	static let body = Self.child(at: 0)
	
	/// A location referring to the anchor's child with given index.
	static func child(at index: Int) -> Self {
		Self(directions: [.position(index)])
	}
	
	/// A location referring to the anchor's child with given identifier.
	static func child(identifiedBy id: some Hashable, position: Int) -> Self {
		Self(directions: [.identifier(.init(id), position: position)])
	}
	
	/// The location's directions, starting with the direction from the anchor.
	private(set) var directions: [Direction]
	enum Direction : Hashable, @unchecked Sendable {
		
		/// The component identified by given position.
		case position(Int)
		
		/// The component identified by given identifier in the mapping component.
		case identifier(AnyHashable, position: Int)
		
	}
	
	/// The location of the component containing the component referred to by `self`, or `nil` if `self` refers to an anchor component.
	var parent: Self? {
		var parent = self
		return parent.directions.popLast() != nil ? parent : nil
	}
	
	/// The locations of the ancestors of the component referred to by `self`, or an empty sequence if `self` refers to an anchor component.
	var ancestors: some Sequence<Self> {
		sequence(first: self, next: \.parent)
			.dropFirst()
	}
	
	/// Returns a location to a child of the component referred by `self`.
	///
	/// - Parameter location: The location from the component referred by `self` to the child. `location`'s anchor is the component referred to by `self`.
	subscript (location: Location) -> Self {
		var child = self
		child.directions.append(contentsOf: location.directions)
		return child
	}
	
	/// Returns a Boolean value indicating whether the component at `self` is an ancestor of the component at `child`.
	///
	/// - Requires: `self` and `child` have the same anchor.
	///
	/// - Parameter child: A location to the potential descendant.
	///
	/// - Returns: `true` if `self` and `child` are equal or if the component at `self` is an ancestor of the component at `child`, and `false` otherwise.
	public func contains(_ child: Self) -> Bool {
		child.directions.starts(with: self.directions)
	}
	
}

extension Location : Comparable {
	public static func < (first: Location, other: Location) -> Bool {
		first.directions.lexicographicallyPrecedes(other.directions)
	}
}

extension Location.Direction : Comparable {
	static func < (first: Location.Direction, other: Location.Direction) -> Bool {
		switch (first, other) {
			
			case (.position(let first), .position(let second)),
				(.identifier(_, position: let first), .identifier(_, position: let second)):
			return first < second
			
			case (.position, _), (_, .position),
				(.identifier, _), (_, .identifier):
			return false	// These combinations do not normally appear as siblings and can be considered unordered if not equal.
			
		}
	}
}
