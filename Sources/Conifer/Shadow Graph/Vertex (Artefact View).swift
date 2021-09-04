// Conifer © 2019–2021 Constantino Tsarouhas

extension Vertex {
	
	/// Returns a view into `self` consisting only of artefacts.
	public var artefacts: ArtefactView {
		.init(base: self)
	}
	
	/// A view into a vertex consisting only of artefacts.
	public struct ArtefactView {
		
		/// The shadow graph into which `self` is a view of.
		fileprivate let base: Vertex
		
	}
	
}
