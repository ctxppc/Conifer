// Conifer © 2019–2023 Constantino Tsarouhas

/// A container component consisting of two components in succession.
///
/// Groups can be nested to create groups of arbitrary size, e.g., a `Group<Group<A, B>, C>` containing three components `A`, `B`, and `C` in succession.
///
/// # Shadow Graph Semantics
///
/// A container component is replaced by its two constituent components in a shadow. A shadow never contains a `Group` but instead a `First` and a `Second` in its place. Since there is an ordering between `First` and `Second`, the structural identities of the first and second component are unique.
public struct Group<First : Component, Second : Component> : Component {
	
	/// Creates a group with given components.
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
	public typealias Con<Third : Component> = Group<Self, Third> /* where Third.Artefact == Artefact */
	
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
	func labelledChildren(for graph: ShadowGraph) async throws -> [(Location, any Component)] {
		[(.anchor[.first], first), (.anchor[.second], second)]
	}
}
