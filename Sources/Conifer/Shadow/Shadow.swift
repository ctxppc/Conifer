// Conifer © 2019–2023 Constantino Tsarouhas

import DepthKit

/// A view into a component and its contents.
@dynamicMemberLookup
public struct Shadow<Shadowed : Component> : Sendable {
	
	/// The graph backing the shadow.
	let graph: ShadowGraph
	
	/// The location of the shadowing component relative to the root component in `graph`.
	let location: Location
	
	/// The shadowing component.
	var shadowed: Shadowed {
		get async throws {
			let component = try await graph[location]
			return component as? Shadowed !! "Expected \(component) to be typed \(Shadowed.self)"
		}
	}
	
	/// Accesses the shadowing component.
	public subscript <Value>(dynamicMember keyPath: KeyPath<Shadowed, Value>) -> Value {
		get async throws {
			try await shadowed[keyPath: keyPath]
		}
	}
	
	/// Accesses a subcomponent.
	subscript <Child : Component>(childLocation: Location) -> Shadow<Child> {
		.init(graph: graph, location: location[childLocation])
	}
	
}
