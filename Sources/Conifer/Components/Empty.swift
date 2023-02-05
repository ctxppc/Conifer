// Conifer © 2019–2023 Constantino Tsarouhas

/// The empty component; a component that represents a component with no body.
///
/// ## Shadow Semantics
///
/// An empty component does not appear in a shadow. A shadow never contains an `Empty`.
public struct Empty : Component {
	
	// See protocol.
	public var body: Never { hasNoBody }
	
}

extension Empty : FoundationalComponent {
	var labelledChildren: [(Location, any Component)] {
		[]
	}
}
