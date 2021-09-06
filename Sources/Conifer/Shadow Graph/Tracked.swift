// Conifer © 2019–2021 Constantino Tsarouhas

/// A value tracking accesses to a shadow graph.
@propertyWrapper
struct Tracked<Graph : ShadowGraphProtocol> : ShadowGraphProtocol {
	
	/// Creates a value tracking accesses to given graph.
	init(wrappedValue: Graph) {
		self.wrappedValue = wrappedValue
	}
	
	/// The shadow graph for which accesses are tracked.
	var wrappedValue: Graph
	
	// See protocol.
	mutating func produce(_ artefact: Graph.Artefact, at location: Location) {
		createdLocations.insert(location)
		wrappedValue.produce(artefact, at: location)
	}
	
	// See protocol.
	mutating func render<C : Component>(_ component: C, at location: Location) async where C.Artefact == Graph.Artefact {
		await wrappedValue.render(component, at: location)
	}
	
	// See protocol.
	mutating func produceHiddenVertex(at location: Location) {
		createdLocations.insert(location)
		wrappedValue.produceHiddenVertex(at: location)
	}
	
	/// The graph locations created during rendering.
	private(set) var createdLocations = Set<ShadowGraphLocation>()
	
	/// The graph locations accessed during rendering.
	private(set) var accessedLocations = Set<ShadowGraphLocation>()
	
}
