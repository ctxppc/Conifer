// Conifer © 2019–2023 Constantino Tsarouhas

/// The non-existent component.
///
/// This component type is used as the type of `body` in foundational components.
///
/// # Shadow Graph Semantics
///
/// No instance of `Never` exists. It can therefore never exist in a shadow.
extension Never : Component {
	public var body: Self { hasNoBody }
}
