// Conifer © 2019–2023 Constantino Tsarouhas

/// A selector of components for which a given predicate holds.
public struct PredicateSelector<Candidates : TypedSelector> {
	
	/// A selector selecting candidates.
	public let candidates: Candidates
	
	/// The indices of the selected components.
	public let predicate: Predicate
	public typealias Predicate = (Shadow<SelectedComponent>) -> Bool
	
}

extension PredicateSelector : TypedSelector {
	public typealias SelectedComponent = Candidates.SelectedComponent
	public func selection(subject: UntypedShadow) -> AsyncFilterSequence<Candidates.TypedSelection> {
		candidates
			.selection(subject: subject)
			.filter(predicate)
	}
}

extension TypedSelector {
	
	/// Derives a selector of components for which `predicate` holds.
	public subscript (where predicate: @escaping PredicateSelector<Self>.Predicate) -> PredicateSelector<Self> {
		.init(candidates: self, predicate: predicate)
	}
	
}
