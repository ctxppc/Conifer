// Conifer © 2019–2024 Constantino Tsarouhas

public struct UntypedShadow : ShadowProtocol {
	
	// TODO: Delete type when it can be expressed as Shadow<any Component>, when Swift supports adding conformances to existentials.
	
	// See protocol.
	let graph: ShadowGraph
	
	// See protocol.
	let location: Location
	
	/// The component represented by `self`.
	var subject: any Component {
		get async throws {
			try await graph[location]
		}
	}
	
}

extension UntypedShadow {
	
	/// Creates an untyped shadow from given typed shadow.
	public init<C>(_ shadow: Shadow<C>) {
		self.graph = shadow.graph
		self.location = shadow.location
	}
	
	/// The type of the component represented by `self`.
	public var subjectType: any Component.Type {
		get async throws {
			type(of: try await subject)
		}
	}
	
	/// Performs a given action on `self`.
	public func perform<A : Action>(_ action: A) async throws -> A.Result {
		try await action.perform(on: self)
	}
	
	/// An action that can be taken on an untyped shadow.
	///
	/// Shadow actions are parametrised over a subject type and can therefore not be expressed as a simple function, since Swift does not support generic function values. Shadow actions are therefore expressed as concrete types conforming to the `ShadowAction` protocol.
	public protocol Action {
		
		/// Performs the action on given shadow.
		func perform<Subject>(on shadow: Shadow<Subject>) async throws -> Result
		
		/// The result of the action.
		associatedtype Result
		
	}
	
}

extension UntypedShadow.Action {
	
	/// Performs the action on a given untyped shadow.
	///
	/// - Parameter shadown: The shadow on which to perform the action.
	///
	/// - Returns: The result of the action.
	fileprivate func perform(on shadow: UntypedShadow) async throws -> Result {
		try await perform(subject: shadow.subject, graph: shadow.graph, location: shadow.location)
	}
	
	/// Performs the action on the shadow specified by a given subject, graph, and graph location.
	///
	/// - Parameters:
	///   - subject: The subject on which to perform the action. The argument is only used by the Swift runtime to open an `any Component` existential and create an appropriate `Shadow` type.
	///   - graph: The shadow graph on which to perform the action.
	///   - location: The location of the shadow on which to perform the action.
	///
	/// - Returns: The result of the action.
	private func perform<Subject : Component>(subject: Subject, graph: ShadowGraph, location: Location) async throws -> Result {
		try await perform(on: Shadow<Subject>(graph: graph, location: location))
	}
	
}
