// Conifer © 2019–2025 Constantino Tsarouhas

/// A value that specifies the location of a component or dynamic property in a shadow graph relative to an anchor.
///
/// A location is a path, i.e., a list of directions starting from the anchor. Each direction identifies the child to visit. When the anchor is a root component, the location is *absolute*; otherwise, it is a *relative* location.
///
/// Locations can be used as stable identifiers across renderings.
///
/// Locations are ordered in pre-order form: ancestors precede their descendants, siblings are ordered normally, and a component's or property's descendants are ordered before the siblings that follow that component or property.
public indirect enum ShadowLocation : Sendable, Hashable {
	
	/// A location that refers to the anchor (or root) component.
	case anchor
	
	/// A location that refers to the body of the component at `parent`.
	case body(parent: Self = .anchor)
	
	/// A location that refers to the body of the component at `self`.
	var body: Self { .body(parent: self) }
	
	/// A location that refers to the child at `position` in the component at `parent`.
	case positionalChild(position: Int, parent: Self = .anchor)
	
	/// Returns location that refers to the child at `position` in the component at `self`.
	func child(at position: Int) -> Self {
		.positionalChild(position: position, parent: self)
	}
	
	/// A location that refers to the child identified by `identifier` in the component at `parent`.
	case child(identifier: AnyIdentifier, position: Int, parent: Self = .anchor)
	
	/// Returns a location that refers to the child identified by `identifier` in the component at `self`.
	func child(identifiedBy identifier: some Identifier, position: Int) -> Self {
		.child(identifier: .init(identifier), position: position, parent: self)
	}
	
	/// The locations of the ancestors of the component referred to by `self`, or an empty sequence if `self` refers to an anchor component.
	var ancestors: some Sequence<Self> {
		sequence(first: self, next: \.parent)
			.dropFirst()
	}
	
	/// The location of the component containing the component referred to by `self`, or `nil` if `self` refers to an anchor component.
	var parent: Self? {
		switch self {
			
			case .anchor:
			return nil
			
			case .body(parent: let parent),
				.positionalChild(position: _, parent: let parent),
				.child(identifier: _, position: _, parent: let parent):
			return parent
			
		}
	}
	
	/// Returns given location after replacing its anchor with `self`.
	///
	/// For example, `.anchor.child(at: 1)[.anchor.body]` is equal to `.anchor.child(at: at).body`.
	subscript (childLocation: Self) -> Self {
		childLocation.replacingAnchor(with: self)
	}
	
	/// Returns `self` after replacing the anchor with given location.
	private func replacingAnchor(with newAnchor: Self) -> Self {
		switch self {
			
			case .anchor:
			return newAnchor
			
			case .body(parent: let parent):
			return .body(parent: parent.replacingAnchor(with: newAnchor))
			
			case .positionalChild(position: let position, parent: let parent):
			return .positionalChild(position: position, parent: parent.replacingAnchor(with: newAnchor))
			
			case .child(identifier: let identifier, position: let position, parent: let parent):
			return .child(identifier: identifier, position: position, parent: parent.replacingAnchor(with: newAnchor))
			
		}
	}
	
}

extension ShadowLocation : Comparable {
	public static func < (lhs: Self, rhs: Self) -> Bool {
		TODO.unimplemented
	}
}
