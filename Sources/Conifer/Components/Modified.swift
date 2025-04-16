// Conifer © 2019–2025 Constantino Tsarouhas

/// A component with a modifier applied to it.
///
/// When the component on which the modified is applied to is a foundational component, the modifier is applied to its direct non-foundational descendants. In the example below, the `.bold` modifier is applied to both the `Title` and `Paragraph` components.
///
///     Group {
///       Title("Hello, World!")
///       Paragraph("Thank you for reading this sentence.")
///     }.modifier(.bold)
///
/// ## Adding Conformance to a Domain-Specific Shadow Protocol
/// Conifer clients that specialise `Component` should add a conditional conformance of `Modified` to that protocol. For example, a web application framework that specialises `Component` as `Element` should add the following conformance:
///
///     extension Modified : Element where Content : Element {}
///
/// Constrain `ModifierType` when this is required by the application.
///
///	    extension ForEach : Element where Body : Element, ModifierType : ElementModifier {}
///
/// Constraints on `ModifierType` do not carry statically over to shadows, which may require the use of forced casts, e.g., `modifier as! any ElementModifier`.
public struct Modified<Content : Component, ModifierType : Modifier> : Component {
	
	/// Applies a given modifier on a given component.
	fileprivate init(content: Content, modifier: ModifierType) {
		self.content = content
		self.modifier = modifier
	}
	
	/// The component whose shadow is modified.
	public let content: Content
	
	/// The modifier.
	public let modifier: ModifierType
	
	// See protocol.
	public var body: Never { hasNoBody }
	
}

extension Modified : FoundationalComponent {
	
	func childLocations(for shadow: some Shadow<Self>) async throws -> [ShadowGraph.Location] {
		[.anchor.body]
	}
	
	func typeOfChild(at location: ShadowGraph.Location, for shadow: some Shadow<Self>) async throws -> any Component.Type {
		Content.self
	}
	
	func child(at location: ShadowGraph.Location, for shadow: some Shadow<Self>) async throws -> any Component {
		precondition(location == .anchor.body, "Expected body location")
		return content
	}
	
	func finalise(_ shadow: some Shadow<Self>) async throws {
		for try await child in shadow.children(ofType: (any Shadow).self) {	// only non-foundational children
			try await modifier.update(child)
		}
	}
	
}

extension Component {
	
	/// Applies a given modifier to `self`.
	public func modifier<M : Modifier>(_ modifier: M) -> Modified<Self, M> {
		.init(content: self, modifier: modifier)
	}
	
}
