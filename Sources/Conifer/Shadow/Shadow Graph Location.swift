// Conifer © 2019–2025 Constantino Tsarouhas

extension ShadowGraph {
	
	/// A value that specifies the location of a component or shadow in a shadow graph relative to an anchor.
	///
	/// A location is a path, i.e., a list of directions starting from the anchor. Each direction identifies the child to visit. When the anchor is a root component, the location is *absolute*; otherwise, it is a *relative* location.
	///
	/// Locations are ordered in pre-order form: ancestors precede their descendants, siblings are ordered normally, and a component's descendants are ordered before the siblings that follow that component.
	public indirect enum Location : Sendable, Hashable {
		
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
		case child(identifier: AnyIdentifier, parent: Self = .anchor)
		
		/// Returns a location that refers to the child identified by `identifier` in the component at `self`.
		func child(identifiedBy identifier: some Identifier) -> Self {
			.child(identifier: .init(identifier), parent: self)
		}
		
		/// The locations of the ancestors of the component referred to by `self`, or an empty sequence if `self` refers to an anchor component.
		var ancestors: some Sequence<Self> {
			sequence(first: self, next: \.parent)
				.dropFirst()
		}
		
		/// The location of the component containing the component referred to by `self`, or `nil` if `self` refers to an anchor component.
		///
		/// - Invariant: `parent` is `nil` *iff* `self` is `.anchor`.
		var parent: Self? {
			get {
				switch self {
						
					case .anchor:
					return nil
					
					case .body(parent: let parent),
						.positionalChild(position: _, parent: let parent),
						.child(identifier: _, parent: let parent):
					return parent
					
				}
			}
			set {
				switch (self, newValue) {
					
					case (.anchor, nil):
					break
					
					case (.anchor, let newParent?):
					preconditionFailure("Cannot set the parent of an anchor to \(newParent)")
					
					case (.body(parent: _), let newParent?):
					self = .body(parent: newParent)
					
					case (.positionalChild(position: let position, parent: _), let newParent?):
					self = .positionalChild(position: position, parent: newParent)
					
					case (.child(identifier: let identifier, parent: _), let newParent?):
					self = .child(identifier: identifier, parent: newParent)
					
					case (.body, nil),
						(.positionalChild, nil),
						(.child, nil):
					preconditionFailure("Cannot delete the parent of non-anchor \(self)")
					
				}
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
				
				case .child(identifier: let identifier, parent: let parent):
				return .child(identifier: identifier, parent: parent.replacingAnchor(with: newAnchor))
				
			}
		}
		
	}
	
}
