// Conifer © 2019–2021 Constantino Tsarouhas

import DepthKit
import Collections
import Foundation

extension Vertex {
	
	/// Returns a view into `self` consisting only of artefacts.
	public var artefacts: ArtefactView {
		.init(base: self)
	}
	
	/// A view into a vertex consisting only of artefacts.
	public struct ArtefactView {
		
		/// Creates a view into `base` consisting only of artefacts.
		///
		/// - Parameter base: The vertex into which to create a view.
		fileprivate init(base: Vertex) {
			self.base = base
			self.children = base
				.flattenedInPreOrder(isLeaf: { vertex, _ in vertex.artefact != nil })
				.lazy
				.compactMap { vertex in
					vertex.artefact.map { artefact in
						Element(artefact: artefact, children: ArtefactView(base: vertex))
					}
				}
		}
		
		/// The vertex into which `self` is a view.
		fileprivate let base: Vertex
		
		/// The artefacts that are the immediate children of `base`.
		fileprivate let children: LazyMapSequence<LazyFilterSequence<LazyMapSequence<LazySequence<PreOrderFlatteningBidirectionalCollection<Vertex>>.Elements, Element?>>, Element>
		
		/// A value representing an artefact in a shadow graph and providing access to that artefact's descendents.
		public struct Element {
			
			/// The artefact represented by `self`.
			public let artefact: Artefact
			
			/// A collection of artefacts that are the direct descendents of the artefact represented by `self`.
			public let children: ArtefactView
			
		}
		
	}
	
}

extension Vertex.ArtefactView : BidirectionalCollection {
	
	public var startIndex: Index {
		.init(base: children.startIndex)
	}
	
	public var endIndex: Index {
		.init(base: children.endIndex)
	}
	
	public subscript (index: Index) -> Element {
		children[index.base]
	}
	
	public func index(before index: Index) -> Index {
		.init(base: children.index(before: index.base))
	}
	
	public func index(after index: Index) -> Index {
		.init(base: children.index(after: index.base))
	}
	
	public struct Index : Comparable {
		
		/// The index in the underlying collection.
		fileprivate let base: PreOrderFlatteningBidirectionalCollection<Vertex>.Index
		
		public static func < (earlier: Self, later: Self) -> Bool {
			earlier.base < later.base
		}
		
	}
	
}
