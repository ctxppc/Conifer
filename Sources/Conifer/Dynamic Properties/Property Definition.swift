// Conifer © 2019–2023 Constantino Tsarouhas

@_spi(Reflection) import ReflectionMirror

/// A definition of a property on a component or dynamic property type.
enum PropertyDefinition : Hashable {
	
	/// A property on a component.
	case componentProperty(AnyKeyPath)
	
	/// A property on a dynamic property with definition `parent`.
	indirect case nestedProperty(AnyKeyPath, parent: Self)
	
	var keyPath: AnyKeyPath {
		switch self {
			case .componentProperty(let keyPath),
				.nestedProperty(let keyPath, parent: _):
			return keyPath
		}
	}
	
}

extension Component {
	
	/// Returns a list of definitions for each property on `Self`.
	static func propertyDefinitions() -> [PropertyDefinition] {
		PartialKeyPath<Self>
			.allKeyPaths()
			.map { .componentProperty($0) }
	}
	
	/// Returns a list of dynamic properties on `self` paired with their definitions.
	func dynamicProperties() -> [(PropertyDefinition, any DynamicProperty)] {
		Self.propertyDefinitions()
			.compactMap { definition in
				(self[keyPath: definition.keyPath] as? any DynamicProperty)
					.map { (definition, $0) }
			}
	}
	
}

extension DynamicProperty {
	
	/// Returns a list of definitions for each property on `Self`.
	static func propertyDefinitions(parent: PropertyDefinition) -> [PropertyDefinition] {
		PartialKeyPath<Self>
			.allKeyPaths()
			.map { .nestedProperty($0, parent: parent) }
	}
	
	/// Returns a list of dynamic properties on `self` paired with their definitions.
	func dynamicProperties(parent: PropertyDefinition) -> [(PropertyDefinition, any DynamicProperty)] {
		Self.propertyDefinitions(parent: parent)
			.compactMap { definition in
				(self[keyPath: definition.keyPath] as? any DynamicProperty)
					.map { (definition, $0) }
			}
	}
	
}

fileprivate extension PartialKeyPath {
	
	/// Returns all key paths from `Root` to properties on `Root`.
	static func allKeyPaths() -> [PartialKeyPath] {
		var definitions = [PartialKeyPath]()
		let success = _forEachFieldWithKeyPath(of: Root.self) { _, keyPath in
			definitions.append(keyPath)
			return true
		}
		precondition(success)
		return definitions
	}
	
}
