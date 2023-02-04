// Conifer © 2019–2023 Constantino Tsarouhas

/// A mapping component; a component that represents a sequence of components generated from an underlying collection of data.
///
/// # Shadow Semantics
///
/// A mapping component is replaced by its generated components in a shadow. A shadow never contains a `ForEach` but instead zero or more `Content`s at the same location.
///
/// The structural identity of each generated component is defined by the `ForEach` component's structural identity and by the identifier provided for that component. This means that the structural identity of a generated component remains the same as long as the `ForEach` component's location within the shadow and the provided identifier don't change.
public struct ForEach<Data : RandomAccessCollection, Identifier : Hashable, Content : Component> : Component {
	
	/// Creates a component that produces components produced by `contentProducer` for each element in `data`, with each component identified by the identifier provided by `identifierProvider`.
	public init(_ data: Data, identifierProvider: @escaping IdentifierProducer, contentProducer: @escaping ContentProducer) {	// TODO: Add component builder annotation
		self.data = data
		self.identifierProvider = identifierProvider
		self.contentProducer = contentProducer
	}
	
	/// The underlying collection.
	public let data: Data
	
	/// A function taking an element from the underlying collection and producing an identifier.
	public let identifierProvider: IdentifierProducer
	public typealias IdentifierProducer = (Data.Element) -> Identifier
	
	/// A function taking an element from the underlying collection and producing a component.
	public let contentProducer: ContentProducer
	public typealias ContentProducer = (Data.Element) -> Content
	
	// See protocol.
	public var body: Never { hasNoBody }
	
}

extension ForEach : FoundationalComponent {
	var labelledChildren: [(Location, any Component)] {
		data.enumerated().map { position, datum in
			(.child(identifiedBy: identifierProvider(datum), position: position), contentProducer(datum))
		}
	}
}

extension ForEach where Data.Element : Identifiable, Identifier == Data.Element.ID {
	
	/// Creates a component that produces components produced by `contentProducer` for each element in `data`, with each component identified by the associated element's identifier.
	public init(_ data: Data, contentProducer: @escaping ContentProducer) {	// TODO: Add component builder annotation
		self.init(data, identifierProvider: \.id, contentProducer: contentProducer)
	}
	
}
