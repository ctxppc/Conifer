// Conifer © 2019–2021 Constantino Tsarouhas

/// A container component consisting of two components in succession.
///
/// Groups can be nested to create groups of arbitrary size, e.g., a `Group<Group<A, B>, C>` containing three components `A`, `B`, and `C` in succession.
///
/// # Shadow Graph Semantics
///
/// The group component is not represented in the artefact view of the shadow graph; it consecutively renders the two components and any produced artefacts are located at the location proposed to the group component.
public struct Group<First : Component, Second : Component> : Component /* where First.Artefact == Second.Artefact */ {
	
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
	public var body: Never/*<Artefact>*/ {
		Never.hasNoBody(self)
	}
	
	// See protocol.
	public func render<G : ShadowGraphProtocol>(in graph: inout G, at location: ShadowGraphLocation) async /* where Artefact == G.Artefact */ {
		await graph.render(first, at: location[ChildIdentifier.first])
		await graph.render(second, at: location[ChildIdentifier.second])
	}
	
	private enum ChildIdentifier : Hashable {
		case first, second
	}
	
	// See protocol.
	/* public typealias Artefact = First.Artefact */
	
}
