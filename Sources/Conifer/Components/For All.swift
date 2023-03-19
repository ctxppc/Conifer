// Conifer © 2019–2023 Constantino Tsarouhas

/// A transformer that selects components using a given selector and replaces them.
///
/// # Shadow Semantics
///
/// A transformer is replaced by its result in a shadow. A shadow never contains a `ForAll` but instead zero or more `Content`s (or their shadow equivalents) at the same location.
///
/// A component containing a transformer such as `ForAll` can only be instantiated using `Shadow(of:transformingFrom:)`. `Shadow(of:)` throws an error when it is used to instantiate a (component containing a) transformer.
public struct ForAll<Selector : TypedSelector, Content : Component> : Component {
	
	/// A function mapping selected components to the result of the transformation.
	let content: ContentProvider
	typealias ContentProvider = @Sendable (Selector.SelectedComponent) -> Content
	
	// See protocol.
	public var body: Never { hasNoBody }
	
}

extension ForAll : FoundationalComponent {
	var labelledChildren: [(Location, any Component)] {
		get async throws {
			TODO.unimplemented
		}
	}
}
