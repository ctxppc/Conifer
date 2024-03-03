// Conifer © 2019–2024 Constantino Tsarouhas

@_spi(Reflection) import ReflectionMirror

/// A reference to a property on a component type or dynamic property type.
enum PropertyReference : Hashable, @unchecked Sendable {	// KeyPath, an immutable class, is not declared Sendable
	
	/// A property on a component.
	case componentProperty(AnyKeyPath)
	
	/// A property on a dynamic property with definition `parent`.
	indirect case nestedProperty(AnyKeyPath, parent: Self)
	
	/// The key path from the component to the property.
	var keyPath: AnyKeyPath {
		switch self {
			case .componentProperty(let keyPath),
				.nestedProperty(let keyPath, parent: _):
			return keyPath
		}
	}
	
}

extension Component {
	
	/// Returns a list of references for each property on `Self`.
	static func propertyReferences() -> [PropertyReference] {
		PartialKeyPath<Self>
			.allKeyPaths()
			.map { .componentProperty($0) }
	}
	
}

extension DynamicProperty {
	
	/// Returns a list of references for each property on `Self`.
	static func propertyReferences(parentReference: PropertyReference) -> [PropertyReference] {
		PartialKeyPath<Self>
			.allKeyPaths()
			.map { .nestedProperty($0, parent: parentReference) }
	}
	
}

fileprivate extension PartialKeyPath {
	
	/// Returns all key paths from `Root` to properties on `Root`.
	static func allKeyPaths() -> [PartialKeyPath] {
		var keyPaths = [PartialKeyPath]()
		let success = _forEachFieldWithKeyPath(of: Root.self) { _, keyPath in
			keyPaths.append(keyPath)
			return true
		}
		precondition(success, "Could not determine all key paths from \(Root.self)")
		return keyPaths
	}
	
}
