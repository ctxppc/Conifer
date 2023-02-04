// Conifer © 2019–2023 Constantino Tsarouhas

import DepthKit

/// A view into a component and its contents.
@dynamicMemberLookup
public struct Shadow<Subject : Component> : Sendable {
	
	/// Creates a typed shadow from given untyped shadow.
	init(_ shadow: UntypedShadow) async throws {
		
		self.graph = shadow.graph
		self.location = shadow.location
		
		let component = try await graph[location]
		self.subject = component as? Subject !! "Expected \(component) to be typed \(Subject.self)"
		
	}
	
	/// The graph backing the shadow.
	let graph: ShadowGraph
	
	/// The location of the subject relative to the root component in `graph`.
	let location: Location
	
	/// The component represented by `self`.
	let subject: Subject
	
	/// Accesses the subject.
	public subscript <Value>(dynamicMember keyPath: KeyPath<Subject, Value>) -> Value {
		subject[keyPath: keyPath]
	}
	
	/// Accesses a subcomponent.
	subscript (childLocation: Location) -> UntypedShadow {
		.init(graph: graph, location: location[childLocation])
	}
	
}

public struct UntypedShadow : Sendable {
	
	/// The graph backing the shadow.
	let graph: ShadowGraph
	
	/// The location of the subject relative to the root component in `graph`.
	let location: Location
	
	/// Accesses a subcomponent.
	subscript (childLocation: Location) -> UntypedShadow {
		.init(graph: graph, location: location[childLocation])
	}
	
}
