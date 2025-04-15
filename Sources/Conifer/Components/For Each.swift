// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

/// A mapping component; a component that represents a sequence of components generated from an underlying collection of data.
///
/// ## Shadow Semantics
///
/// A mapping component is replaced by its generated components in a shadow. A shadow never contains a `ForEach` but instead zero or more `Content`s (or their shadow equivalents) at the same location.
///
/// The structural identity of each generated component is defined by the `ForEach` component's structural identity and by the identifier provided for that component. This means that the structural identity of a generated component remains the same as long as the `ForEach` component's location within the shadow and the provided identifier don't change.
public struct ForEach<Data : RandomAccessCollection & Sendable, Identifier : Conifer.Identifier, Content : Component> : Component {
	
	/// Creates a component that produces components produced by `content` for each element in `data`, with each component identified by the identifier provided by `id`.
	public init(_ data: Data, id: @escaping IdentifierProducer, @ComponentBuilder content: @escaping ContentProducer) {
		self.data = data
		self.id = id
		self.content = content
	}
	
	/// The underlying collection.
	public let data: Data
	
	/// A function taking an element from the underlying collection and producing an identifier.
	public let id: IdentifierProducer
	public typealias IdentifierProducer = @Sendable (Data.Element) -> Identifier
	
	/// A function taking an element from the underlying collection and producing a component.
	public let content: ContentProducer
	public typealias ContentProducer = @Sendable (Data.Element) -> Content
	
	// See protocol.
	public var body: Never { hasNoBody }
	
}

extension ForEach : FoundationalComponent {
	
	func childLocations(for shadow: some Shadow<Self>) async throws -> [ShadowGraph.Location] {
		let ids = data.map(id)
		try await shadow.set(
			\.offsetsByIdentifier,
			 .init(uniqueKeysWithValues: ids.enumerated().lazy.map { (.init($1), $0) })
		)
		return ids.map { .anchor.child(identifiedBy: $0) }
	}
	
	func typeOfChild(at location: ShadowGraph.Location, for shadow: some Shadow<Self>) async throws -> any Component.Type {
		Content.self
	}
	
	func child(at location: ShadowGraph.Location, for shadow: some Shadow<Self>) async -> any Component {
		guard case .child(identifier: let id, parent: .anchor) = location else {
			preconditionFailure("No child at \(location) in \(self)")
		}
		guard let offset = await shadow.offsetsByIdentifier[id] else {
			preconditionFailure("No child identified by \(id) in \(self)")
		}
		return content(data[data.index(data.startIndex, offsetBy: offset)])
	}
	
}

extension ForEach where Data.Element : Identifiable, Identifier == Data.Element.ID {
	
	/// Creates a component that produces components produced by `contentProducer` for each element in `data`, with each component identified by the associated element's identifier.
	public init(_ data: Data, @ComponentBuilder content: @escaping ContentProducer) {
		self.init(data, id: \.id, content: content)
	}
	
}

private extension ShadowSnapshot {
	
	/// The offsets of each element, keyed by their identifier.
	var offsetsByIdentifier: [AnyIdentifier : Int] {
		get { self[\.offsetsByIdentifier] ?? [:] }
		set { self[\.offsetsByIdentifier] = newValue }
	}
	
}
