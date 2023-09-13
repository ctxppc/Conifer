// Conifer © 2019–2023 Constantino Tsarouhas

/// An actor that tracks a dependency of a component.
public protocol Dependency : AnyActor {
	
	/// A sequence of changes to the tracked value.
	///
	/// The dependent component is rerendered when a change is observed.
	var changes: Changes { get }
	associatedtype Changes : AsyncSequence
	typealias Change = Changes.Element
	
}
