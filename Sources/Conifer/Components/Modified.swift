// Conifer © 2019–2024 Constantino Tsarouhas

/// A component with a modifier applied to it.
///
/// When the component on which the modified is applied to is a foundational component, the modifier is applied to its direct non-foundational descendants. In the example below, the `.bold` modifier is applied to both the `Title` and `Paragraph` components.
///
///     Group {
///       Title("Hello, World!")
///       Paragraph("Thank you for reading this sentence.")
///     }.modifier(.bold)
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
	
	func childLocations(for shadow: some Shadow<Self>) async throws -> [Location] {
		[.body]
	}
	
	func child(at location: Location, for shadow: some Shadow<Self>) async throws -> any Component {
		precondition(location == .body, "Expected body direction")
		return content
	}
	
	func finalise(_ shadow: some Shadow<Self>) async throws {
		for try await child in shadow.children(ofType: Shadow.self) {	// only non-foundational children
			await child.update(shadow)
		}
	}
	
}

extension Component {
	
	/// Applies a given modifier to `self`.
	public func modifier<M : Modifier>(_ modifier: M) -> Modified<Self, M> {
		.init(content: self, modifier: modifier)
	}
	
}

public protocol Modifier : Sendable {
	
	/// Modifies a given shadowed component.
	func update(_ shadow: some Shadow) async throws
	
}
