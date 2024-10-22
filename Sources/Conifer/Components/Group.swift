// Conifer © 2019–2024 Constantino Tsarouhas

/// A container component consisting of two components in succession.
///
/// Groups can be nested to create groups of arbitrary size, e.g., a `Group<Group<A, B>, C>` containing three components `A`, `B`, and `C` in succession.
///
/// ## Shadow Semantics
///
/// A container component is replaced by its two constituent components in a shadow. A shadow never contains a `Group` but instead a `First` and a `Second` in its place. Since there is an ordering between `First` and `Second`, the structural identities of the first and second component are unique.
public struct Group<First : Component, Second : Component> : Component {	// TODO: Replace with type parameter pack when compiler issues are sorted out.
	
	/// Creates a group with given children.
	public init(_ first: First, _ second: Second) {
		self.first = first
		self.second = second
	}
	
	/// Creates a group using given closure.
	public init(@ComponentBuilder _ contents: () -> Self) {
		self = contents()
	}
	
	/// The first component.
	public let first: First
	
	/// The second component.
	public let second: Second
	
	/// A type that allows concatenating a third component to groups of this type.
	///
	/// This convenience syntax allows writing `Group<A, B>.Con<C>` instead of `Group<Group<A, B>, C>`.
	public typealias Con<Third : Component> = Group<Self, Third>
	
	/// Concatenates a third component to this group.
	///
	/// This convenience syntax allows writing `Group(a, b).con(c)` instead of `Group(Group(a, b), c)`.
	public func con<Third : Component>(_ third: Third) -> Self.Con<Third> {
		.init(self, third)
	}
	
	// See protocol.
	public var body: Never { hasNoBody }
	
}

extension Group : FoundationalComponent {
	
	func childLocations(for shadow: some Shadow<Self>) async throws -> [Location] {
		[.child(at: 0), .child(at: 1)]
	}
	
	func child(at location: Location, for shadow: some Shadow<Self>) async throws -> any Component {
		switch location {
			case .child(at: 0):	return first
			case .child(at: 1):	return second
			default:			preconditionFailure("\(location) does not exist on \(shadow)")
		}
	}
	
}
