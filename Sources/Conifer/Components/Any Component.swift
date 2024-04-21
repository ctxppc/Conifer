// Spin © 2019–2024 Constantino Tsarouhas

/// A type-erased container containing a single component.
///
/// ## Shadow Semantics
///
/// A type-erased container over a non-foundational component is replaced by the latter in a shadow. A type-erased container over a foundational component is replaced in a shadow by the non-foundational children produced by the foundational component.
public struct AnyComponent : FoundationalComponent {
	
	// TODO: Remove type when any Component can be made to conform to FoundationalComponent.
	
	/// Creates a type-erased container around a given component.
	public init<C : Component>(_ wrapped: C) {
		switch wrapped {
			
			case let wrapped as any FoundationalComponent:
			self.wrapped = .foundational(labelledChildrenProvider: wrapped.labelledChildren(for:))
			
			case let wrapped as Self:
			self = wrapped
			
			default:
			self.wrapped = .nonfoundational(wrapped)
			
		}
	}
	
	private let wrapped: Wrapped
	private enum Wrapped {
		case nonfoundational(any Component)
		case foundational(labelledChildrenProvider: (ShadowGraph) async throws -> [(Location, any Component)])
	}
	
	// See protocol.
	public var body: Never { hasNoBody }
	
	// See protocol.
	func labelledChildren(for graph: ShadowGraph) async throws -> [(Location, any Component)] {
		switch wrapped {
			case .nonfoundational(let wrapped):					return [(.child(at: 0), wrapped)]
			case .foundational(let labelledChildrenProvider):	return try await labelledChildrenProvider(graph)
		}
	}
	
}
