// Conifer © 2019–2023 Constantino Tsarouhas

/// A component's location in a shadow relative to an anchor.
public struct Location : Hashable, @unchecked Sendable {	// AnyHashable isn't Sendable
	
	/// The location referring to the anchor.
	static let anchor = Self(directions: [])
	
	/// A location referring to the body of the (non-foundational) anchor.
	static let body = Self(directions: [.body])
	
	/// A location referring to the first component of the anchor conditional.
	static let firstOfConditional = Self(directions: [.firstOfConditional])
	
	/// A location referring to the second component of the anchor conditional.
	static let secondOfConditional = Self(directions: [.secondOfConditional])
	
	/// A location referring to the first component of the anchor group.
	static let firstOfGroup = Self(directions: [.firstOfGroup])
	
	/// A location referring to the second component of the anchor group.
	static let secondOfGroup = Self(directions: [.secondOfGroup])
	
	/// A location referring to the anchor's child with given identifier.
	static func child(identifiedBy id: some Hashable) -> Self {
		Self(directions: [.identifier(.init(id))])
	}
	
	/// The location's directions, starting with the direction from the anchor.
	private var directions: [Direction]
	private enum Direction : Hashable, @unchecked Sendable {
		
		/// The body of the (non-foundational) component.
		case body
		
		/// The first component of the conditional.
		case firstOfConditional
		
		/// The second component of the conditional.
		case secondOfConditional
		
		/// The first component of the group.
		case firstOfGroup
		
		/// The second component of the group.
		case secondOfGroup
		
		/// The component identified by given identifier in the mapping component.
		case identifier(AnyHashable)
		
	}
	
	/// The location of the component containing the component referred to by `self`.
	var parent: Self {
		var parent = self
		parent.directions.removeLast()
		return parent
	}
	
	/// Returns a location to a child of the component referred by `self`.
	///
	/// - Parameter location: The location from the component referred by `self` to the child.
	subscript (location: Location) -> Self {
		var child = self
		child.directions.append(contentsOf: location.directions)
		return child
	}
	
}
