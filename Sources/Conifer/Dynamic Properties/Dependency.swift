// Conifer © 2019–2024 Constantino Tsarouhas

/// An actor that tracks a dependency of a component.
///
/// The system creates a dependency for each dynamic property when the dependent component is first rendered as part of a shadow graph. The system then tracks the dependency to determine when to rerender the component.
public protocol Dependency : AnyActor {
	
	/// A sequence of changes to the tracked value.
	///
	/// The dependent component is rerendered when a change is observed.
	var changes: Changes { get }
	associatedtype Changes : AsyncSequence
	typealias Change = Changes.Element
	
}
