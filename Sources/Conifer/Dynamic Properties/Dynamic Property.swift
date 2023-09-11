// Conifer © 2019–2023 Constantino Tsarouhas

import Foundation

/// A property of a component whose value is determined outside of the component.
///
/// Dynamic properties are a mechanism wherein components can retrieve information that hasn't been passed down through traditional means like during initialisation. These values might be provided by ancestor components (cf. `Contextual`) or from an external source such as a database.
///
/// Dynamic properties can only be declared within components and only be used from within a rendering context such as the `body` property or the `render(in:context:)` method. The system ensures that all declared dynamic properties are properly populated before rendering begins. Additionally, the system records these properties as dependencies of the component; whenever any dynamic property changes, the system re-renders the component.
public protocol DynamicProperty {
	
	// TODO
	
}

enum DynamicPropertyError : LocalizedError {
	
	/// A dynamic property is used in a component that renders an artefact type not supported by the dynamic property.
	case unsupportedArtefactType(Any.Type, dynamicProperty: DynamicProperty)
	
	// See protocol.
	var errorDescription: String? {
		switch self {
			case .unsupportedArtefactType(let type, dynamicProperty: let property):
			return "Dynamic property \(property) cannot be used in components rendering artefacts of type \(type)"
		}
	}
	
}
