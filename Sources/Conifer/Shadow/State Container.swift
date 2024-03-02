// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit

/// A mapping of state properties to their values for a component.
struct StateContainer : Sendable {
	
	/// Accesses a value in the state container.
	///
	/// - Requires: `self` already contains a value for `definition`, or such a value is being set.
	subscript <Value : Sendable>(definition: PropertyDefinition) -> Value {
		
		get {
			let value = valueByPropertyDefinition[definition] !! "Missing value for \(definition) in state container"
			return value as? Value !! "Expected state value \(value) of type \(Value.self)"
		}
		
		set {
			valueByPropertyDefinition[definition] = newValue
		}
		
	}
	
	/// The container's storage.
	private var valueByPropertyDefinition = [PropertyDefinition : any Sendable]()
	
}
