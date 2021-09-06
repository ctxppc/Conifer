// Conifer © 2019–2021 Constantino Tsarouhas

/// A mapping component; a component that represents a sequence of components generated from an underlying collection of data.
///
/// # Shadow Graph Semantics
///
/// The mapping component is not represented in the artefact view of the shadow graph; it consecutively renders the generated components and any produced artefacts are located at the location proposed to the mapping component.
///
/// The conditional component has an identity for each generated component, directly derived from the corresponding element's identifier. The identity lives as long as the corresponding element. This means that every generated component has its own state, preserved as long as the data element in the underlying collection exists.
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
	public var body: Never<Artefact> {
		Never.hasNoBody(self)
	}
	
	// See protocol.
	public func render<G : ShadowGraphProtocol>(in graph: inout G, at location: ShadowGraphLocation) async where Content.Artefact == G.Artefact {
		for element in data {
			await graph.render(contentProducer(element), at: location[identifierProvider(element)])
		}
	}
	
	// See protocol.
	public typealias Artefact = Content.Artefact
	
}

extension ForEach where Data.Element : Identifiable, Identifier == Data.Element.ID {
	
	/// Creates a component that produces components produced by `contentProducer` for each element in `data`, with each component identified by the associated element's identifier.
	public init(_ data: Data, contentProducer: @escaping ContentProducer) {	// TODO: Add component builder annotation
		self.init(data, identifierProvider: \.id, contentProducer: contentProducer)
	}
	
}
