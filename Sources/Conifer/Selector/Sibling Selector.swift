// Conifer © 2019–2023 Constantino Tsarouhas

import DepthKit

public struct SiblingSelector<Predecessor : Selector> {
	
	/// A selector selecting the sibling.
	let sibling: Predecessor
	
	/// The offset of the selected component in the sibling list, where positive offsets follow the component selected by `sibling`.
	let offset: Int
	
}

extension SiblingSelector : Selector {
	public func selection(subject: UntypedShadow) -> AsyncThrowingCompactMapSequence<Predecessor.Selection, UntypedShadow> {
		sibling
			.selection(subject: subject)
			.compactMap { sibling -> UntypedShadow? in
				guard let parentLocation = sibling.location.parent else { return nil }
				let graph = sibling.graph
				let siblingLocations = try await graph.childLocations(ofComponentAt: parentLocation)
				let siblingIndex = siblingLocations.firstIndex(of: subject.location) !! "Expected sibling index"
				return UntypedShadow(graph: graph, location: siblingLocations[siblingIndex + offset])
			}
	}
}

extension Selector {
	
	/// Derives a selector that selects the predecessor of the components selected by `self`.
	public var predecessor: SiblingSelector<Self> {
		.init(sibling: self, offset: -1)
	}
	
	/// Derives a selector that selects the successor of the components selected by `self`.
	public var successor: SiblingSelector<Self> {
		.init(sibling: self, offset: +1)
	}
	
	/// Derives a selector that selects the sibling offset by `offset` of the components selected by `self`.
	public func sibling(offset: Int) -> SiblingSelector<Self> {
		.init(sibling: self, offset: offset)
	}
	
}
