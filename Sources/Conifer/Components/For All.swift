// Conifer © 2019–2023 Constantino Tsarouhas

import DepthKit

/// A transformer that selects components using a given selector and replaces them.
///
/// # Shadow Semantics
///
/// A transformer is replaced by its result in a shadow. A shadow never contains a `ForAll` but instead zero or more `Content`s (or their shadow equivalents) at the same location.
///
/// A component containing a transformer such as `ForAll` can only be instantiated using `Shadow(of:transformingFrom:)` with a non-`nil` transformation source.
public struct ForAll<Selector : TypedSelector, Identifier : Hashable & Sendable, Content : Component> : Component {
	
	/// Creates a transformer that selects components using `selector` on the transformation source and replaces them by the components returned by `content`.
	public init(_ selector: Selector, @ComponentBuilder content: @escaping ContentProvider) {
		self.selector = selector
		self.subject = nil
		self.content = content
	}
	
	/// Creates a transformer that selects components using `selector` on `subject` and replaces them by the components returned by `content`.
	public init<C>(_ selector: Selector, in subject: Shadow<C>, @ComponentBuilder content: @escaping ContentProvider) {
		self.selector = selector
		self.subject = .init(subject)
		self.content = content
	}
	
	/// A selector selecting components to be replaced.
	let selector: Selector
	
	/// A shadow over the component that is the subject of `subject`, or `nil` if the subject is the transformation source.
	let subject: UntypedShadow?
	
	/// A function mapping selected components to the result of the transformation.
	let content: ContentProvider
	public typealias ContentProvider = @Sendable (Shadow<Selector.SelectedComponent>) -> Content
	
	// See protocol.
	public var body: Never { hasNoBody }
	
}

extension ForAll : FoundationalComponent {
	func labelledChildren(for graph: ShadowGraph) async throws -> [(Location, any Component)] {
		try await selector
			.selection(subject: subject ?? graph.transformationSource !! "ForAll transformer used in a shadow without a transformation source")
			.collect()
			.enumerated()
			.map { index, shadow -> (Location, any Component) in
				(.child(identifiedBy: shadow.location, position: index), content(shadow))
			}
	}
}
