// Conifer © 2019–2026 Constantino Tsarouhas

/// A value applied on a component that modifies the component's shadow.
public protocol Modifier : Sendable {
	
	/// Modifies the shadow of the nearest non-foundational component on which `self` is applied.
	func update(_ shadow: some Shadow) async throws
	
}
