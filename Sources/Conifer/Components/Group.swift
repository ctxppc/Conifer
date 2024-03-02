// Conifer © 2019–2024 Constantino Tsarouhas

/// A container component consisting of two components in succession.
///
/// Groups can be nested to create groups of arbitrary size, e.g., a `Group<Group<A, B>, C>` containing three components `A`, `B`, and `C` in succession.
///
/// # Shadow Graph Semantics
///
/// A container component is replaced by its two constituent components in a shadow. A shadow never contains a `Group` but instead a `First` and a `Second` in its place. Since there is an ordering between `First` and `Second`, the structural identities of the first and second component are unique.
public struct Group<each Child : Component> : Component {
	
	/// Creates a group with given children.
	public init(_ child: repeat each Child) {
		self.child = (repeat each child)
	}
	
	/// Creates a group using given closure.
	public init(@ComponentBuilder _ contents: () -> Self) {
		self = contents()
	}
	
	/// The group's children.
	public let child: (repeat each Child)
	
	// See protocol.
	public var body: Never { hasNoBody }
	
}

extension Group : FoundationalComponent {
	func labelledChildren(for graph: ShadowGraph) async throws -> [(Location, any Component)] {
		
		var result = [(Location, any Component)]()
		var index = 0
		func add(_ child: some Component) {
			result.append((.child(at: index), child))
			index += 1
		}
		repeat add(each child)
		
		return result	// TODO: Replace by `[repeat each child].enumerated().map { … }` when apple/swift#67192 is resolved.
		
	}
}
