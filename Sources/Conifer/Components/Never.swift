// Conifer © 2019–2021 Constantino Tsarouhas

/// The non-existent component.
///
/// This component type can be used as the type of `body` in components which implement rendering in the `render(in:at:)` method.
public enum Never<Artefact : Conifer.Artefact> : Component {
	
	// See protocol.
	public var body: Self {
		switch self {}
	}
	
	// See protocol.
	public func render<G : ShadowGraphProtocol>(in graph: inout G, at location: ShadowGraphLocation) async where Artefact == G.Artefact {
		switch self {}
	}
	
}
