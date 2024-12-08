// Conifer © 2019–2024 Constantino Tsarouhas

extension Component {
	
	/// Prepares `self` for rendering.
	///
	/// This method prepares the dynamic properties declared on `self`.
	///
	/// - Parameter shadow: The shadow of `self`.
	mutating func prepareForRendering(shadow: some Shadow<Self>) async throws {
		for keyPath in PartialKeyPath<Self>.allKeyPaths() {
			try await prepareProperty(at: keyPath, forRendering: shadow)
		}
	}
	
	/// Prepares the property at `keyPath` on `self` for rendering.
	///
	/// This method does nothing if the property at `keyPath` is not a stored property whose type conforms to `DynamicProperty`.
	///
	/// - Parameter keyPath: The key path from `self` to the property to prepare.
	/// - Parameter shadow: A shadow of `self`.
	private mutating func prepareProperty(at keyPath: PartialKeyPath<Self>, forRendering shadow: some Shadow<Self>) async throws {
		guard let keyPath = keyPath as? any DynamicPropertyKeyPath<Self> else { return }
		try await keyPath.prepareDynamicProperty(on: &self, forRendering: shadow)
	}
	
}

/// A key path from a component to a (stored) dynamic property.
private protocol DynamicPropertyKeyPath<Root> {
	
	/// A value on which `self` can be applied to.
	associatedtype Root : Component
	
	/// A value that `self` evaluates to when applied.
	associatedtype Value : DynamicProperty
	
	/// Prepares the dynamic property `component[keyPath: self]` for rendering `shadow`.
	func prepareDynamicProperty(on component: inout Root, forRendering shadow: some Shadow<Root>) async throws
	
}

extension WritableKeyPath : DynamicPropertyKeyPath where Root : Component, Value : DynamicProperty {
	func prepareDynamicProperty(on component: inout Root, forRendering shadow: some Shadow<Root>) async throws {
		try await component[keyPath: self].update(for: shadow, keyPath: self)
	}
}

extension WritableKeyPath : @unchecked @retroactive Sendable where Root : Component, Value : DynamicProperty {}
