// Conifer © 2019–2023 Constantino Tsarouhas

/// A value that selects components of a given type for a given root.
public protocol TypedSelector<SelectedComponent> : Selector {
	
	/// A component that the selector selects.
	associatedtype SelectedComponent : Component
	
	/// Returns selected components for `root`.
	func selection(root: UntypedShadow) -> TypedSelection
	associatedtype TypedSelection : AsyncSequence where TypedSelection.Element == Shadow<SelectedComponent>
	
}

extension TypedSelector {
	public func selection(root: UntypedShadow) -> AsyncMapSequence<TypedSelection, UntypedShadow> {
		(selection(root: root) as TypedSelection)
			.map { UntypedShadow($0) }
	}
}
