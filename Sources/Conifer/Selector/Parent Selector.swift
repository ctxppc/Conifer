// Conifer © 2019–2023 Constantino Tsarouhas

/// A selector of parents of given children.
public struct ParentSelector<Children : Selector> {
	
	/// A selector selecting children.
	let children: Children
	
}

extension ParentSelector : Selector {
	public func selection(root: UntypedShadow) -> AsyncThrowingCompactMapSequence<Children.Selection, UntypedShadow> {
		children
			.selection(root: root)
			.compactMap { try await $0.parent }
	}
}

extension Selector {
	
	/// Derives a selector of the parents of the components selected by `self`.
	public var parents: ParentSelector<Self> {
		.init(children: self)
	}
	
}
