// Conifer © 2019–2023 Constantino Tsarouhas

/// An sequence of shadows of non-foundational child components.
public struct ShadowChildren : AsyncSequence {	// TODO: Make private when AsyncSequence gets a primary associated type.
	
	let parentShadow: any ShadowProtocol	// Existential to avoid having to expose ShaodwProtocol and thus ShadowGraph
	// TODO: Replace with Shadow<C> with generic Component parameter C when ShadowProtocol is deleted.
	
	public func makeAsyncIterator() -> AsyncIterator {
		.init(for: parentShadow)
	}
	
	public typealias Element = UntypedShadow
	
	public struct AsyncIterator : AsyncIteratorProtocol {
		
		/// Creates an iterator of shadows of non-foundational child components of `parentShadow`'s subject.
		fileprivate init(for parentShadow: some ShadowProtocol) {
			self.init(graph: parentShadow.graph, parentLocation: parentShadow.location)
		}
		
		/// Creates an iterator of shadows of non-foundational child components of the component at `parentLocation` in `graph`.
		private init(graph: ShadowGraph, parentLocation: Location) {
			self.graph = graph
			self.parentLocation = parentLocation
		}
		
		/// The graph backing `self`.
		private let graph: ShadowGraph
		
		/// The location of the parent component relative to the root component in `graph`.
		private let parentLocation: Location
		
		/// The iterator's state.
		private var state: State = .initial
		private enum State {
			
			/// The iterator hasn't been used yet.
			case initial
			
			/// The iterator is iterating through the parent component's children.
			///
			/// - Parameter childLocations: A list of locations of children of the parent component that are to be returned or traversed.
			case shallow(childLocations: ArraySlice<Location>)
			
			/// The iterator provides nested children provided by a subiterator before resuming iteration through the parent component's children.
			///
			/// - Parameter 1: An iterator providing nested children.
			/// - Parameter childLocations: A list of locations of children of the parent component that are to be returned or traversed after processing the nested iterator.
			indirect case deep(AsyncIterator, childLocations: ArraySlice<Location>)
			
		}
		
		// See protocol.
		public mutating func next() async throws -> UntypedShadow? {
			switch state {
				
				case .initial:
				state = .shallow(childLocations: try await graph.childLocations(ofComponentAt: parentLocation)[...])
				return try await next()
				
				case .shallow(childLocations: var childLocations):
				guard let childLocation = childLocations.popFirst() else { return nil }
				let child = await graph[prerendered: childLocation]
				if child is any FoundationalComponent {
					state = .deep(.init(graph: graph, parentLocation: childLocation), childLocations: childLocations)
					return try await next()
				} else {
					state = .shallow(childLocations: childLocations)
					return .init(graph: graph, location: childLocation, subject: child)
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
