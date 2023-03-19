// Conifer © 2019–2023 Constantino Tsarouhas

/// A selector of components of a given type.
public struct TypeSelector<Candidates : Selector, SelectedComponent : Component> {
	
	/// A selector selecting candidates.
	public let candidates: Candidates
	
}

extension TypeSelector : TypedSelector {
	public func selection(subject: UntypedShadow) -> AsyncThrowingCompactMapSequence<Candidates.Selection, Shadow<SelectedComponent>> {
		candidates
			.selection(subject: subject)
			.compactMap { try await Shadow<SelectedComponent>($0) }
	}
}

extension Selector {
	
	/// Derives a selector that selects all components typed `C` out of the components selected by `self`.
	public subscript <C>(typed type: C.Type) -> TypeSelector<Self, C> {
		.init(candidates: self)
	}
	
}
