// Conifer © 2019–2021 Constantino Tsarouhas

extension ShadowGraph {
	
	/// Returns a view into `self` consisting only of artefact vertices.
	public var artefacts: ArtefactView {
		.init(base: self, rootLocation: .root)
	}
	
	/// A view into a shadow graph consisting only of artefact vertices.
	public struct ArtefactView {
		
		/// The shadow graph into which `self` is a view of.
		private(set) var base: ShadowGraph
		
		/// The location of the root vertex whose descendents the view extends over.
		let rootLocation: Location
		
		// TODO
		
	}
	
}
