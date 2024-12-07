// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit

/// An sequence of shadows of non-foundational child components.
public struct ShadowChildren<Parent : Shadow, Element> : AsyncSequence {
	
	/// The shadow of the parent component whose children are generated by `self`.
	let parentShadow: Parent
	
	// See protocol.
	public func makeAsyncIterator() -> AsyncIterator {
		.init(for: parentShadow)
	}
	
	// See protocol.
	public struct AsyncIterator : AsyncIteratorProtocol {
		
		/// Creates an iterator of shadows of non-foundational child components of `parentShadow`'s subject.
		fileprivate init(for parentShadow: Parent) {
			self.init(graph: parentShadow.graph, parentLocation: parentShadow.location)
		}
		
		/// Creates an iterator of shadows of non-foundational child components of the component at `parentLocation` in `graph`.
		private init(graph: ShadowGraph, parentLocation: ShadowLocation) {
			self.graph = graph
			self.state = .initial(parentLocation: parentLocation)
		}
		
		/// The graph backing `self`.
		private let graph: ShadowGraph
		
		/// The iterator's state.
		private var state: State
		private enum State {
			
			/// The iterator hasn't been used yet.
			///
			/// - Parameter parentLocation: The location of the parent component relative to the root component in `graph`.
			case initial(parentLocation: ShadowLocation)
			
			/// The iterator is iterating through the parent component's children.
			///
			/// - Parameter childLocations: A list of locations of (already rendered) children of the parent component that are to be returned or traversed.
			case shallow(childLocations: ArraySlice<ShadowLocation>)
			
			/// The iterator provides nested children provided by a subiterator before resuming iteration through the parent component's children.
			///
			/// - Parameter 1: An iterator providing nested children.
			/// - Parameter childLocations: A list of (already rendered) locations of children of the parent component that are to be returned or traversed after processing the nested iterator.
			indirect case deep(AsyncIterator, childLocations: ArraySlice<ShadowLocation>)
			
		}
		
		// See protocol.
		public mutating func next() async throws -> Element? {
			switch state {
				
			case .initial(parentLocation: let location):
				state = .shallow(childLocations: try await graph.childLocations(ofComponentAt: location)[...])	// triggers a render if needed
				return try await next()
				
				case .shallow(childLocations: var childLocations):
				guard let childLocation = childLocations.popFirst() else { return nil }
				let child = await graph[prerendered: childLocation]
				if child is any FoundationalComponent {
					state = .deep(.init(graph: graph, parentLocation: childLocation), childLocations: childLocations)	// same Element type
					return try await next()
				} else {
					state = .shallow(childLocations: childLocations)
					let childShadow = child.makeUntypedShadow(graph: graph, location: childLocation)
					return childShadow as? Element !! "Expected child of \(Parent.self) to be \(Element.self); got a \(type(of: childShadow)) instead"
				}
				
				case .deep(var nestedChildren, childLocations: let childLocations):
				if let child = try await nestedChildren.next() {
					state = .deep(nestedChildren, childLocations: childLocations)
					return child
				} else {
					state = .shallow(childLocations: childLocations)
					return try await next()
				}
				
			}
		}
		
	}
	
}
