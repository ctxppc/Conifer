// Conifer © 2019–2024 Constantino Tsarouhas

extension Component {
	
	/// Updates the dynamic properties declared on `self`.
	///
	/// - Parameter shadow: A shadow over `self`.
	mutating func updateDynamicProperties(for shadow: some Shadow<Self>) async throws {
		for keyPath in Self.allDynamicPropertyKeyPaths() {
			try await keyPath.updateDynamicProperty(on: &self, shadow: shadow)
		}
	}
	
	/// Returns key paths from `Self` to each dynamic property on `Self`.
	private static func allDynamicPropertyKeyPaths() -> some Sequence<any DynamicPropertyKeyPath<Self>> {
		PartialKeyPath<Self>
			.allStoredPropertyKeyPaths()
			.lazy
			.compactMap { $0 as? any DynamicPropertyKeyPath<Self> }
	}
	
}

private extension DynamicProperty {
	
	/// Returns key paths from `C` to each dynamic property on `Self`.
	///
	/// - Parameter prefix: A key path of dynamic properties from `C` to `Self`.
	static func allDynamicPropertyKeyPaths<C : Component>(prefix: WritableKeyPath<C, Self>) -> some Sequence<any DynamicPropertyKeyPath<C>> {
		PartialKeyPath<Self>
			.allStoredPropertyKeyPaths()
			.lazy
			.compactMap { (prefix as AnyKeyPath).appending(path: $0) }
			.compactMap { $0 as? any DynamicPropertyKeyPath<C> }
	}
	
}

/// A key path from a component to a (stored, possibly nested) dynamic property.
private protocol DynamicPropertyKeyPath<Root> {
	
	/// A value on which `self` can be applied to.
	associatedtype Root : Component
	
	/// A value that `self` evaluates to when applied.
	associatedtype Value : DynamicProperty
	
	/// Updates the dynamic property of `component` at `self`.
	///
	/// This method first updates the property's nested dynamic properties (if there are any) before updating the property itself.
	///
	/// - Parameters:
	///    - component: The component whose dynamic property to update.
	///    - shadow: A shadow over `component`.
	func updateDynamicProperty(on component: inout Root, shadow: some Shadow<Root>) async throws
	
}

extension WritableKeyPath : DynamicPropertyKeyPath where Root : Component, Value : DynamicProperty {
	func updateDynamicProperty(on component: inout Root, shadow: some Shadow<Root>) async throws {
		for nestedKeyPath in Value.allDynamicPropertyKeyPaths(prefix: self) {
			try await nestedKeyPath.updateDynamicProperty(on: &component, shadow: shadow)
		}
		try await component[keyPath: self].update(for: shadow, keyPath: self)
	}
}

extension WritableKeyPath : @unchecked @retroactive Sendable where Root : Component, Value : DynamicProperty {}
