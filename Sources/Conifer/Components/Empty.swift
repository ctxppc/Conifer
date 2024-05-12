// Conifer © 2019–2024 Constantino Tsarouhas

/// The empty component; a component that represents a component with no body.
///
/// ## Shadow Semantics
///
/// An empty component does not appear in a shadow. A shadow never contains an `Empty`.
public struct Empty : Component {	// TODO: Delete when Group<> doesn't cause a compiler crash.
	
	/// Creates an empty component.
	public init() {}
	
	// See protocol.
	public var body: Never { hasNoBody }
	
}

extension Empty : FoundationalComponent {
	
	func childLocations(for shadow: some Shadow<Self>) async throws -> [Location] {
		[]
	}
	
	func child(at location: Location, for shadow: some Shadow<Self>) async throws -> any Component {
		preconditionFailure("\(shadow) does not contain children")
	}
	
}
