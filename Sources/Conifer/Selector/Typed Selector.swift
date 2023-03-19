// Conifer © 2019–2023 Constantino Tsarouhas

/// A value that selects components of a given type for a given subject.
public protocol TypedSelector<SelectedComponent> : Selector {
	
	/// A component that the selector selects.
	associatedtype SelectedComponent : Component
	
	/// Returns selected components for `subject`.
	func selection(subject: UntypedShadow) -> TypedSelection
	associatedtype TypedSelection : AsyncSequence where TypedSelection.Element == Shadow<SelectedComponent>
	
}

extension TypedSelector {
	public func selection(subject: UntypedShadow) -> AsyncMapSequence<TypedSelection, UntypedShadow> {
		(selection(subject: subject) as TypedSelection)
			.map { UntypedShadow($0) }
	}
}
