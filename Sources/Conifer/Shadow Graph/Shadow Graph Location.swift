// Conifer © 2019–2021 Constantino Tsarouhas

/// A value that refers to a vertex of the shadow graph.
public struct ShadowGraphLocation : Hashable {
	
	/// The path components identifying consecutive vertices starting from the root element.
	///
	/// The array is empty iff `self` identifies the root element.
	private var pathComponents: [AnyHashable]
	
	/// Returns a location that refers to a vertex identified by `identifier` that is a child of the vertex `self` refers to.
	///
	/// - Parameter identifier: The identifier of the child vertex.
	///
	/// - Returns: A location that refers to a vertex identified by `identifier` that is a child of the vertex `self` refers to.
	public func descending<Identifier : Hashable>(toChildIdentifiedBy identifier: Identifier) -> Self {
		with(self) {
			$0.pathComponents.append(.init(identifier))
		}
	}
	
	/// Returns a location that refers to the parent vertex of the vertex `self` refers to.
	///
	/// - Returns: A location that refers to the parent vertex of the vertex `self` refers to.
	public func ascending() -> Self {
		with(self) {
			$0.pathComponents.removeLast()
		}
	}
	
}

extension ShadowGraphProtocol {
	
	/// A value that refers to an element of the shadow graph.
	public typealias Location = ShadowGraphLocation
	
}
