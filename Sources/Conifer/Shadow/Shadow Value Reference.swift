// Conifer © 2019–2025 Constantino Tsarouhas

/// An untyped reference to a shadow value, i.e., to some shadow property on some shadow.
struct AnyShadowValueReference : Sendable, Hashable {
	
	// TODO: Replace by ShadowValueReferenceProtocol when any ShadowValueReferenceProtocol conforms to Equatable & Hashable.
	
	/// The location of the shadow in the graph.
	var location: ShadowGraph.Location
	
	/// A key path from a shadow snapshot to the shadow value.
	var property: ShadowSnapshot.AnyProperty
	
}

/// A reference to a shadow value, i.e., to some shadow property of type `Value` on some shadow.
struct ShadowValueReference<Value> : Sendable, Hashable {
	
	/// The location of the shadow in the graph.
	var location: ShadowGraph.Location
	
	/// A key path from a shadow snapshot to the shadow value.
	var property: ShadowSnapshot.Property<Value>
	
}
