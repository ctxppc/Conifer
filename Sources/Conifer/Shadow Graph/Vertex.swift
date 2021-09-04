// Conifer © 2019–2021 Constantino Tsarouhas

import Collections

/// A vertex in a shadow graph.
public struct Vertex {
	
	/// An empty vertex.
	public static let empty = Self(contents: .structure(childrenByIdentifier: [:]))
	
	/// A hidden vertex.
	public static let hidden = Self(contents: .hidden)
	
	/// The vertex' contents.
	var contents: Contents
	enum Contents {
		
		/// The vertex is a structure.
		case structure(childrenByIdentifier: OrderedDictionary<AnyHashable, Vertex> = [:])
		
		/// The vertex is an artefact.
		case artefact(Artefact, childrenByIdentifier: OrderedDictionary<AnyHashable, Vertex> = [:])
		
		/// The vertex is hidden.
		case hidden
		
	}
	
	/// The artefact on `self`, or `nil` if `self` does not contain an artefact.
	public var artefact: Artefact? {
		switch contents {
			case .artefact(let artefact, childrenByIdentifier: _):	return artefact
			case .structure, .hidden:								return nil
		}
	}
	
	/// Returns a Boolean value indicating that `self` is a hidden vertex.
	public var isHidden: Bool {
		switch contents {
			case .structure, .artefact:	return false
			case .hidden:				return true
		}
	}
	
	/// Produces an artefact on `self`.
	///
	/// - Requires: `self` is not hidden and does not contain an artefact.
	public mutating func produce(_ artefact: Artefact) {
		switch contents {
			
			case .structure(childrenByIdentifier: let childrenByIdentifier):
			contents = .artefact(artefact, childrenByIdentifier: childrenByIdentifier)
			
			case .artefact(let existing, childrenByIdentifier: _):
			preconditionFailure("Cannot replace \(existing) with \(artefact). Artefacts cannot be replaced or deleted.")
			
			case .hidden:
			preconditionFailure("Cannot replace hidden vertex with \(artefact). Vertices cannot be replaced or deleted.")
			
		}
	}
	
	/// Produces a hidden vertex on `self`.
	///
	/// - Requires: `self` is empty and does not contain an artefact.
	public mutating func produceHiddenVertex() {
		switch contents {
			
			case .structure(childrenByIdentifier: let childrenByIdentifier):
			precondition(childrenByIdentifier.isEmpty, "Cannot replace non-empty structure with hidden vertex. Vertices cannot be replaced or deleted.")
			contents = .hidden
			
			case .artefact(let existing, childrenByIdentifier: _):
			preconditionFailure("Cannot replace \(existing) with hidden vertex. Artefacts cannot be replaced or deleted.")
			
			case .hidden:
			return
			
		}
	}
	
}
