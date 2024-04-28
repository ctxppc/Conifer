// Spin © 2019–2024 Constantino Tsarouhas

/// A type-erased container containing a single component.
///
/// ## Shadow Semantics
///
/// A type-erased container over a non-foundational component is replaced by the latter in a shadow. A type-erased container over a foundational component is replaced in a shadow by the non-foundational children produced by the foundational component.
public struct AnyComponent : Component {
	
	// TODO: Remove type when (any Component) can be made to conform to FoundationalComponent.
	
	/// Creates a type-erased container around a given component.
	public init(_ wrapped: some Component) {
		switch wrapped {
			case let wrapped as Self:						self = wrapped
			case let wrapped as any FoundationalComponent:	self.wrapped = .foundational(wrapped)
			default:										self.wrapped = .ordinary(wrapped)
		}
	}
	
	/// The type-erased component.
	private let wrapped: Wrapped
	private enum Wrapped {
		case foundational(any FoundationalComponent)
		case ordinary(any Component)
	}
	
	// See protocol.
	public var body: Never { hasNoBody }
	
}

extension AnyComponent : FoundationalComponent {
	
	func childLocations(for shadow: Shadow<Self>) async throws -> [Location] {
		switch wrapped {
			
			case .foundational(let wrapped):
			return try await wrapped.childLocations(graph: shadow.graph, location: shadow.location)
			
			case .ordinary:
			return [.body]
			
		}
	}
	
	func child(at location: Location, for shadow: Shadow<Self>) async throws -> any Component {
		switch wrapped {
			
			case .foundational(let wrapped):
			return try await wrapped.child(at: location, graph: shadow.graph, parentLocation: shadow.location)
			
			case .ordinary(let wrapped):
			precondition(location == .body, "Expected body direction")
			return try await wrapped.body
			
		}
	}
	
}

private extension FoundationalComponent {
	
	func childLocations(graph: ShadowGraph, location: Location) async throws -> [Location] {
		try await childLocations(for: .init(graph: graph, location: location))
	}
	
	func child(at childLocation: Location, graph: ShadowGraph, parentLocation: Location) async throws -> any Component {
		try await child(at: childLocation, for: .init(graph: graph, location: parentLocation))
	}
	
}
