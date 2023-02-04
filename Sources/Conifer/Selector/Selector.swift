// Conifer © 2019–2023 Constantino Tsarouhas

/// A predicate over components in a shadow.
public protocol Selector {
	
	/// Returns the results of the selector when applied on `subject`.
	func results<SubjectComponent>(on subject: Shadow<SubjectComponent>) async throws -> UntypedResults
	associatedtype UntypedResults : AsyncSequence where UntypedResults.Element == UntypedShadow
	
}

/// A predicate over components in a shadow.
public protocol TypedSelector<ResultComponent> : Selector {
	
	/// A component that the selector selects.
	associatedtype ResultComponent : Component
	
	/// Returns the results of the selector when applied on `subject`.
	func results<SubjectComponent>(on subject: Shadow<SubjectComponent>) async throws -> TypedResults
	associatedtype TypedResults : AsyncSequence where TypedResults.Element == Shadow<ResultComponent>
	
}
