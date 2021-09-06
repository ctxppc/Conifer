// Conifer © 2019–2021 Constantino Tsarouhas

/// The non-existent component.
///
/// This component type can be used as the type of `body` in components which implement rendering in the `render(in:at:)` method.
public enum Never<Artefact> : Component {
	
	// See protocol.
	public var body: Self {
		Self.hasNoBody(self)
	}
	
	// See protocol.
	public func render<G : ShadowGraphProtocol>(in graph: inout G, at location: ShadowGraphLocation) async where Artefact == G.Artefact {
		switch self {}
	}
	
	/// Termines the program with an error message stating that `component` has no body.
	public static func hasNoBody<C : Component>(_ component: C) -> Self where C.Artefact == Artefact {
		fatalError("\(component) has no body")
	}
	
}
