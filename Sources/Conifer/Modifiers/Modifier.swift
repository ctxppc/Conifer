// Conifer © 2019–2025 Constantino Tsarouhas

/// A value applied on a component that modifies the component's shadow.
public protocol Modifier : Sendable {
	
	/// Modifies the shadow of a component `self` is applied to.
	func update(_ shadow: some Shadow) async throws
	
}
