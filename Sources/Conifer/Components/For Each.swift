// Conifer © 2019–2021 Constantino Tsarouhas

/// A mapping component; a component that represents a sequence of components generated from an underlying collection of data.
///
/// # Shadow Graph Semantics
///
/// The mapping component is not represented in the artefact graph; it consecutively renders the generated components at the graph location proposed to the mapping component.
///
/// The conditional component has an identity for each generated component, directly derived from the corresponding element's identifier. The identity lives as long as the corresponding element. This means that every generated component has its own state, preserved as long as the data element in the underlying collection exists.
public struct ForEach<Data : RandomAccessCollection, Identifier : Hashable, Content : Component> {
	
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
	public var body: Never<Artefact> {
		fatalError("\(self) has no body.")
	}
	
	// See protocol.
	public func render(in graph: inout ShadowGraph<Artefact>, at location: ShadowGraphLocation) async {
		TODO.unimplemented
	}
	
	// See protocol.
	public typealias Artefact = Content.Artefact
	
}
