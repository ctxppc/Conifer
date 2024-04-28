// Conifer © 2019–2024 Constantino Tsarouhas

/// A structural element in a component tree with no semantic meaning.
///
/// This protocol enables Conifer to treat its structural component types specially. This power is not afforded to Conifer clients which get a simplified API instead.
protocol FoundationalComponent : Component where Body == Never {
	
	/// Returns a tuple for each child of `self`, with each tuple consisting of a component and the location of that component relative to `self`.
	///
	/// The component must not query itself or any of its descendants on the shadow graph.
	///
	/// - Parameter graph: The shadow graph performing the request.
	func labelledChildren(for graph: ShadowGraph) async throws -> [(Location, any Component)]
	
	/// Performs additional post-rendering actions on the shadow of `self`.
	///
	/// `shadow` is a shadow over a foundational component and hence must not be passed to Conifer clients.
	///
	/// This method may trigger additional renderings during its execution if `shadow`'s descendants are accessed.
	///
	/// The default implementation does nothing.
	func finalise(_ shadow: Shadow<Self>) async throws
	
}

extension FoundationalComponent {
	
	// See protocol.
	func finalise(_ shadow: Shadow<Self>) async throws {}
	
	/// Terminates the program with an error message stating that `self` has no body.
	var hasNoBody: Never {
		fatalError("\(self) has no body")
	}
	
}
