// Conifer © 2019–2024 Constantino Tsarouhas

/// A definition of a dynamic property on a component or dynamic property.
struct DynamicPropertyDefinition : Sendable {
	
	/// The property reference.
	var propertyReference: PropertyReference
	
	/// The dynamic property.
	var dynamicProperty: any DynamicProperty
	
}

extension Component {
	
	/// Returns a list of dynamic property definitions on `self`.
	func dynamicPropertyDefinitions() -> [DynamicPropertyDefinition] {
		Self.propertyReferences()
			.compactMap { definition in
				(self[keyPath: definition.keyPath] as? any DynamicProperty)
					.map { .init(propertyReference: definition, dynamicProperty: $0) }
			}
	}
	
}

extension DynamicProperty {
	
	/// Returns a list of dynamic property definitions on `self`.
	func dynamicPropertyDefinitions(parentReference: PropertyReference) -> [DynamicPropertyDefinition] {
		Self.propertyReferences(parentReference: parentReference)
			.compactMap { definition in
				(self[keyPath: definition.keyPath] as? any DynamicProperty)
					.map { .init(propertyReference: definition, dynamicProperty: $0) }
			}
	}
	
}
