// Conifer © 2019–2023 Constantino Tsarouhas

/// A component's location in a shadow relative to an anchor.
///
/// Locations are ordered in pre-order form: ancestors precede their descendants, siblings are ordered normally, and a component's descendants are ordered before the siblings that follow that component.
struct Location : Hashable, @unchecked Sendable {	// AnyHashable isn't Sendable
	
	/// The location referring to the anchor.
	static let anchor = Self(directions: [])
	
	/// A location referring to the body of the (non-foundational) anchor.
	static let body = Self(directions: [.body])
	
	/// A location referring to the first component of the anchor conditional or group.
	static let first = Self(directions: [.first])
	
	/// A location referring to the second component of the anchor conditional or group.
	static let second = Self(directions: [.second])
	
	/// A location referring to the anchor's child with given identifier.
	static func child(identifiedBy id: some Hashable, position: Int) -> Self {
		Self(directions: [.identifier(.init(id), position: position)])
	}
	
	/// The location's directions, starting with the direction from the anchor.
	private var directions: [Direction]
	fileprivate enum Direction : Hashable, @unchecked Sendable {
		
		/// The body of the (non-foundational) component.
		case body
		
		/// The first component of the conditional or group.
		case first
		
		/// The second component of the conditional or group.
		case second
		
		/// The component identified by given identifier in the mapping component.
		case identifier(AnyHashable, position: Int)
		
	}
	
	/// The location of the component containing the component referred to by `self`, or `nil`.
	var parent: Self? {
		var parent = self
		return parent.directions.popLast() != nil ? parent : nil
	}
	
	/// The location of the non-foundational component containing the component referred to by `self`.
	var observableParent: Self {
		TODO.unimplemented
	}
	
	/// Returns a location to a child of the component referred by `self`.
	///
	/// - Parameter location: The location from the component referred by `self` to the child.
	subscript (location: Location) -> Self {
		var child = self
		child.directions.append(contentsOf: location.directions)
		return child
	}
	
	/// Returns a Boolean value indicating whether the component at `self` is an ancestor of the component at `child`.
	///
	/// - Parameter child: A location to the potential descendant.
	///
	/// - Returns: `true` if `self` and `child` are equal or if the component at `self` is an ancestor of the component at `child`, and `false` otherwise.
	func contains(_ child: Self) -> Bool {
		child.directions.starts(with: self.directions)
	}
	
}

extension Location : Comparable {
	static func < (first: Location, other: Location) -> Bool {
		first.directions.lexicographicallyPrecedes(other.directions)
	}
}

extension Location.Direction : Comparable {
	static func < (first: Location.Direction, other: Location.Direction) -> Bool {
		switch (first, other) {
			
			case (.first, .second):
			return true
			
			case (.second, .first):
			return false
			
			case (.identifier(_, position: let first), .identifier(_, position: let second)):
			return first < second
			
			case (.first, _), (_, .first),
				(.second, _), (_, .second),
				(.body, _), (_, .body),
				(.identifier, _), (_, .identifier):
			return false	// These combinations do not normally appear as siblings and can be considered unordered if not equal.
			
		}
	}
}
