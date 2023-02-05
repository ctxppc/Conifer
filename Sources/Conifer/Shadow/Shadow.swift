// Conifer © 2019–2023 Constantino Tsarouhas

import DepthKit

/// A view into a component and its contents.
///
/// Unlike shadow graphs, foundational components do not appear in shadows, i.e., `Subject` does not conform to `FoundationalComponent`.
@dynamicMemberLookup
public struct Shadow<Subject : Component> : ShadowProtocol {
	
	/// Creates a typed shadow from given untyped shadow.
	init(_ shadow: UntypedShadow) async throws {
		
		self.graph = shadow.graph
		self.location = shadow.location
		
		let component = try await graph[location]
		self.subject = component as? Subject !! "Expected \(component) to be typed \(Subject.self)"
		
	}
	
	// See protocol.
	let graph: ShadowGraph
	
	// See protocol.
	let location: Location
	
	/// The component represented by `self`.
	let subject: Subject
	
	/// Accesses the subject.
	public subscript <Value>(dynamicMember keyPath: KeyPath<Subject, Value>) -> Value {
		subject[keyPath: keyPath]
	}
	
	/// The subject's children.
	///
	/// - Invariant: No component in `body` is a foundational component.
	public var body: _ShadowBody {	// TODO: Replace by `some AsyncSequence<UntypedShadow>` when AsyncSequence gets a primary associated type.
		.init(parentShadow: self)
	}
	
	// See protocol.
	subscript (childLocation: Location) -> UntypedShadow {
		.init(graph: graph, location: location[childLocation])
	}
	
	/// The parent component, or `nil` if `self` is a root component.
	///
	/// - Invariant: `parent` is not a foundational component.
	var parent: UntypedShadow? {
		get async throws {
			for location in sequence(first: location, next: \.parent) {
				if !(try await graph[location] is any FoundationalComponent) {
					return .init(graph: graph, location: location)
				}
			}
			return nil
		}
	}
	
}

public struct UntypedShadow : ShadowProtocol {
	
	// See protocol.
	let graph: ShadowGraph
	
	// See protocol.
	let location: Location
	
	// See protocol.
	subscript (childLocation: Location) -> UntypedShadow {
		.init(graph: graph, location: location[childLocation])
	}
	
}

protocol ShadowProtocol : Sendable {
	
	/// The graph backing `self`.
	var graph: ShadowGraph { get }
	
	/// The location of the subject relative to the root component in `graph`.
	var location: Location { get }
	
	/// Accesses a subcomponent.
	///
	/// - Invariant: `childLocation` is a valid location.
	subscript (childLocation: Location) -> UntypedShadow { get }
	
}

/// An sequence of shadows of non-foundational child components.
public struct _ShadowBody : AsyncSequence {				// TODO: Make private when AsyncSequence gets a primary associated type.
	
	fileprivate let parentShadow: any ShadowProtocol	// TODO: Replace with generic parameter when AsyncSequence gets a primary associated type.
	
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
			/// - Parameter childLocations: A list of locations of children of the parent component that are to be returned or traversed.
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
				if try await graph[childLocation] is any FoundationalComponent {
					state = .deep(.init(graph: graph, parentLocation: childLocation), childLocations: childLocations)
					return try await next()
				} else {
					state = .shallow(childLocations: childLocations)
					return .init(graph: graph, location: childLocation)
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
