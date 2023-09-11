// Conifer © 2019–2023 Constantino Tsarouhas

/// A structural element in a component tree with no semantic meaning.
///
/// This protocol enables Conifer to treat its structural component types specially. This power is not afforded to Conifer clients which get a simplified API instead.
protocol FoundationalComponent : Component where Body == Never {
	
	/// Returns a tuple for each child of `self`, with each tuple consisting of a component and the location of that component relative to `self`.
	///
	/// - Parameter graph: The shadow graph performing the request. The component must not query itself or any of its descendants on the shadow graph.
	func labelledChildren(for graph: ShadowGraph) async throws -> [(Location, any Component)]
	
}

extension FoundationalComponent {
	
	/// Terminates the program with an error message stating that `self` has no body.
	var hasNoBody: Never {
		fatalError("\(self) has no body")
	}
	
}
