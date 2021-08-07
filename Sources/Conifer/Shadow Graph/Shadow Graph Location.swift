// Conifer © 2019–2021 Constantino Tsarouhas

extension ShadowGraph {
	
	/// A value that can be used to navigate through a shadow graph.
	public struct Location : Hashable, Comparable {
		
		public static func < (smaller: Location, greater: Location) -> Bool {
			smaller.indices.lexicographicallyPrecedes(greater.indices)
		}
		
		/// The indices
		private var indices: [Int]
		
	}
	
}
