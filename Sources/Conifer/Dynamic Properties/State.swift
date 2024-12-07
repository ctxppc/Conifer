// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit

/// A dynamic property whose lifetime is shared with the component's shadow.
///
/// When a component is rendered, Conifer updates each `State` value used as a property wrapper in the component value or in any of its dynamic properties with
@propertyWrapper
public struct State<Value : Sendable> : DynamicProperty {
	
	/// Creates a state property with given inital value.
	public init(wrappedValue: Value) {
		self.storedValue = wrappedValue
	}
	
	// See protocol.
	public mutating func update(for shadow: some Shadow, propertyIdentifier: some Hashable & Sendable) async {
		
		// If state container already has a value, replace the initial value.
		if let value: Value = await shadow.element(ofType: StateContainer.self)?[propertyIdentifier] {
			storedValue = value
		}
		
		backReference = .init(shadow: shadow, propertyIdentifier: propertyIdentifier)
		
	}
	
	// See protocol.
	public var wrappedValue: Value {
		get { storedValue }
		set {
			storedValue = newValue
			if let backReference {
				Task { [newValue] in
					var container = await backReference.shadow.element(ofType: StateContainer.self) ?? .init()
					container[backReference.propertyIdentifier] = newValue
					// FIXME: Other updates to the container between the suspention points are lost.
					await backReference.shadow.update(container)
				}
			}
		}
	}
	
	/// The backing value.
	private var storedValue: Value
	
	/// A reference to the shadow graph.
	private var backReference: BackReference?
	private struct BackReference : Sendable {
		let shadow: any Shadow
		let propertyIdentifier: any Hashable & Sendable
	}
	
}

/// A mapping of state properties to their values for a component.
private struct StateContainer : @unchecked Sendable {	// AnyHashable with Sendable bases only
	
	/// Accesses a value in the state container.
	subscript <Value : Sendable>(propertyIdentifier: some Hashable & Sendable) -> Value? {
		
		get {
			guard let value = valuesByPropertyIdentifier[propertyIdentifier] else { return nil }
			return value as? Value !! "Expected state value of type \(Value.self); got \(value) instead"
		}
		
		set {
			valuesByPropertyIdentifier[propertyIdentifier] = newValue
		}
		
	}
	
	/// The container's storage.
	private var valuesByPropertyIdentifier = [AnyHashable : any Sendable]()
	
}
