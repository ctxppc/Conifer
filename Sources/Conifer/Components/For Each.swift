// Conifer © 2019–2021 Constantino Tsarouhas

/// A mapping component; a component that represents a sequence of components generated from an underlying collection of data.
///
/// # Shadow Graph Semantics
///
/// The mapping component is not represented in the shadow graph; it renders the generated components directly in the graph, starting from the location proposed to the mapping component.
public struct ForEach<Data : Collection, Content : Component> {
	
	/// Creates a component that produces components produced by `contentProducer` for each element in `data`.
	public init(_ data: Data, contentProducer: @escaping ContentProducer) {	// TODO: Add component builder annotation
		self.data = data
		self.contentProducer = contentProducer
	}
	
	/// The underlying collection.
	public let data: Data
	
	/// A function taking an element from the underlying collection and producing a component.
	public let contentProducer: ContentProducer
	public typealias ContentProducer = (Data.Element) -> Content
	
	// See protocol.
	public var body: Empty<Content.Artefact, Content.Context> {
		.init()
	}
	
	// TODO
	
}
