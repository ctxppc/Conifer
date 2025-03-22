// Conifer © 2019–2025 Constantino Tsarouhas

/// A directed graph with no loops or cycles and no more than one edge between any two vertices.
struct SimpleDirectedAcyclicGraph<Vertex : Sendable & Hashable> : Sendable, Hashable {
	
	/// A dictionary mapping each source vertex to its destination vertices.
	private var destinationVerticesBySourceVertex: [Vertex : Set<Vertex>] = [:]
	
	/// A dictionary mapping each origin vertex to all vertices reachable from the origin.
	private var reachableVerticesByOriginVertex: [Vertex : Set<Vertex>] = [:]
	
	/// Adds an edge from a given source vertex to a given destination vertex, if such an edge does not exist already.
	mutating func addEdge(from source: Vertex, to destination: Vertex) throws(CyclicError) {
		
		let verticesReachableFromDestination = {
			if let v = reachableVerticesByOriginVertex[destination] {
				return v
			} else {
				let v: Set<Vertex> = [destination]
				reachableVerticesByOriginVertex[destination] = v
				return v
			}
		}()
		
		guard !verticesReachableFromDestination.contains(source) else { throw .cycle(source) }
		
		reachableVerticesByOriginVertex[source, default: [source]].formUnion(verticesReachableFromDestination)
		
		destinationVerticesBySourceVertex[source, default: []].insert(destination)
		
	}
	
	/// Returns a Boolean value indicating whether the graph has an edge from a given source vertex to a given destination vertex.
	func hasEdge(from source: Vertex, to destination: Vertex) -> Bool {
		destinationVerticesBySourceVertex[source]?.contains(destination) ?? false
	}
	
	/// Returns all vertices out-neighbouring a given vertex, i.e., all destination vertices for which there is an edge between given source vertex and the destination vertex.
	func vertices(succeeding source: Vertex) -> Set<Vertex> {
		destinationVerticesBySourceVertex[source] ?? []
	}
	
	/// Returns all vertices reachable from a given vertex.
	func vertices(reachableFrom source: Vertex) -> Set<Vertex> {
		reachableVerticesByOriginVertex[source] ?? [source]
	}
	
	enum CyclicError : Error {
		case cycle(Vertex)
	}
	
}
