// Conifer © 2019–2023 Constantino Tsarouhas

/// A selector of components at a given index range.
public struct IndexSelector<Candidates : Selector> {
	
	/// A selector selecting candidates.
	public let candidates: Candidates
	
	/// The indices of the selected components.
	public let indices: Range<Int>
	
}

extension IndexSelector : Selector {
	public func selection(subject: UntypedShadow) -> AsyncPrefixSequence<AsyncDropFirstSequence<Candidates.Selection>> {
		candidates
			.selection(subject: subject)
			.dropFirst(indices.startIndex)
			.prefix(indices.count)
	}
}

extension IndexSelector : TypedSelector where Candidates : TypedSelector {
	public typealias SelectedComponent = Candidates.SelectedComponent
	public func selection(subject: UntypedShadow) -> AsyncPrefixSequence<AsyncDropFirstSequence<Candidates.TypedSelection>> {
		candidates
			.selection(subject: subject)
			.dropFirst(indices.startIndex)
			.prefix(indices.count)
	}
}

extension Selector {
	
	/// Creates a selector that selects the component at position `index` out of the components selected by `self`.
	public subscript (index: Int) -> IndexSelector<Self> {
		.init(candidates: self, indices: .init(index...index))
	}
	
	/// Creates a selector that selects the components at positions specified by `range` out of the components selected by `self`.
	public subscript (range: Range<Int>) -> IndexSelector<Self> {
		.init(candidates: self, indices: range)
	}
	
}
