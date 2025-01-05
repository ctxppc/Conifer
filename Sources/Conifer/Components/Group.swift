// Conifer © 2019–2025 Constantino Tsarouhas

/// A container component consisting of any number components in succession.
///
/// ## Shadow Semantics
///
/// A group is replaced by its constituent components in a shadow. A shadow never contains a `Group` but instead its children in its place.
public struct Group<each Child : Component> : Component {
	
	/// Creates a group with given children.
	public init(_ children: repeat each Child) {
		self.children = (repeat each children)
	}
	
	/// Creates a group using given closure.
	public init(@ComponentBuilder _ contents: () -> Self) {
		self = contents()
	}
	
	/// The children.
	public let children: (repeat each Child)
	
	// See protocol.
	public var body: Never { hasNoBody }
	
}

extension Group : FoundationalComponent {
	
	func childLocations(for shadow: some Shadow<Self>) async throws -> [ShadowGraph.Location] {
		var locations = [ShadowGraph.Location]()
		var position = 0
		for _ in repeat each children {
			locations.append(.anchor.child(at: position))
			position += 1
		}
		return locations
	}
	
	func child(at location: ShadowGraph.Location, for shadow: some Shadow<Self>) async throws -> any Component {
		
		guard case .positionalChild(position: let desiredPosition, parent: .anchor) = location else {
			preconditionFailure("\(location) does not refer to a positional child in \(shadow)")
		}
		
		var position = 0
		for child in repeat each children {
			if position == desiredPosition {
				return child
			}
			position += 1
		}
		
		preconditionFailure("\(shadow) does not have a child at position \(desiredPosition)")
		
	}
	
}
