// Conifer © 2019–2024 Constantino Tsarouhas

/// A mapping component; a component that represents a sequence of components generated from an underlying collection of data.
///
/// ## Shadow Semantics
///
/// A mapping component is replaced by its generated components in a shadow. A shadow never contains a `ForEach` but instead zero or more `Content`s (or their shadow equivalents) at the same location.
///
/// The structural identity of each generated component is defined by the `ForEach` component's structural identity and by the identifier provided for that component. This means that the structural identity of a generated component remains the same as long as the `ForEach` component's location within the shadow and the provided identifier don't change.
public struct ForEach<Data : RandomAccessCollection & Sendable, Identifier : Hashable & Sendable, Content : Component> : Component {
	
	/// Creates a component that produces components produced by `contentProducer` for each element in `data`, with each component identified by the identifier provided by `identifierProvider`.
	public init(
		_ data:								Data,
		identifierProvider:					@escaping IdentifierProducer,
		@ComponentBuilder contentProducer:	@escaping ContentProducer
	) {
		self.data = data
		self.identifierProvider = identifierProvider
		self.contentProducer = contentProducer
	}
	
	/// The underlying collection.
	public let data: Data
	
	/// A function taking an element from the underlying collection and producing an identifier.
	public let identifierProvider: IdentifierProducer
	public typealias IdentifierProducer = @Sendable (Data.Element) -> Identifier
	
	/// A function taking an element from the underlying collection and producing a component.
	public let contentProducer: ContentProducer
	public typealias ContentProducer = @Sendable (Data.Element) -> Content
	
	// See protocol.
	public var body: Never { hasNoBody }
	
}

extension ForEach : FoundationalComponent {
	
	func childLocations(for shadow: Shadow<Self>) -> [Location] {
		data.enumerated().map { position, datum in
			.child(identifiedBy: identifierProvider(datum), position: position)
		}
	}
	
	func child(at location: Location, for shadow: Shadow<Self>) -> any Component {
		precondition(location.directions.count == 1, "Expected one direction")
		guard case .identifier(_, position: let offset) = location.directions.first else { preconditionFailure("Expected identifier direction") }
		return contentProducer(data[data.index(data.startIndex, offsetBy: offset)])
	}
	
}

extension ForEach where Data.Element : Identifiable, Identifier == Data.Element.ID {
	
	/// Creates a component that produces components produced by `contentProducer` for each element in `data`, with each component identified by the associated element's identifier.
	public init(_ data: Data, @ComponentBuilder contentProducer: @escaping ContentProducer) {
		self.init(data, identifierProvider: \.id, contentProducer: contentProducer)
	}
	
}
