// Conifer © 2019–2023 Constantino Tsarouhas

public struct ChildSelector<Parent : Selector> : Selector {
	
	/// The selector for the parents.
	let parent: Parent
	
	// See protocol.
	public func results<SubjectComponent>(on subject: Shadow<SubjectComponent>) async throws -> AsyncStream<UntypedShadow> {
		TODO.unimplemented
	}
	
}
