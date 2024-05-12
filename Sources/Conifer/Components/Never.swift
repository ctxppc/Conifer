// Conifer © 2019–2024 Constantino Tsarouhas

/// The non-existent component.
///
/// This component type is used as the type of `body` in foundational components.
///
/// ## Shadow Semantics
///
/// No instance of `Never` exists. It can therefore never exist in a shadow.
extension Never : Component {
	public var body: Self { hasNoBody }
}

extension Never : FoundationalComponent {
	
	func childLocations(for shadow: some Shadow<Self>) async throws -> [Location] {
		switch self {}
	}
	
	func child(at location: Location, for shadow: some Shadow<Self>) async throws -> any Component {
		switch self {}
	}
	
}
