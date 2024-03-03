// Conifer © 2019–2024 Constantino Tsarouhas

public struct UntypedShadow : ShadowProtocol {
	
	// TODO: Delete type when it can be expressed as Shadow<any Component>, when Swift supports adding conformances to existentials.
	
	// See protocol.
	let graph: ShadowGraph
	
	// See protocol.
	let location: Location
	
	/// The component represented by `self`.
	var subject: any Component {
		get async throws {
			try await graph[location]
		}
	}
	
}

extension UntypedShadow {
	
	/// Creates an untyped shadow from given typed shadow.
	public init<C>(_ shadow: Shadow<C>) {
		self.graph = shadow.graph
		self.location = shadow.location
	}
	
}
