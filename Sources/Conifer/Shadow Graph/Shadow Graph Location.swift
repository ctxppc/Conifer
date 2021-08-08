// Conifer © 2019–2021 Constantino Tsarouhas

extension ShadowGraph {
	
	/// A value that can be used to navigate through a shadow graph.
	public typealias Location = ShadowGraphLocation
	
}

/// A value that can be used to navigate through a shadow graph.
public struct ShadowGraphLocation : Hashable, Comparable {
	
	private var indices: [Int]
	
	public static func < (smaller: Self, greater: Self) -> Bool {
		smaller.indices.lexicographicallyPrecedes(greater.indices)
	}
	
}
