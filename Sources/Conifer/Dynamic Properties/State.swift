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
	public mutating func update(for shadow: UntypedShadow, propertyIdentifier: some Hashable & Sendable) async {
		guard let value: Value = await shadow.element(ofType: StateContainer.self)?[propertyIdentifier] else { return }
		storedValue = value
	}
	
	// See protocol.
	public var wrappedValue: Value {
		get { storedValue }
		set {
			storedValue = newValue
			if let backReference {
				Task {
					await backReference.shadow.update(default: StateContainer()) { container in
						container[backReference.propertyIdentifier] = newValue
					}
				}
			}
		}
	}
	
	/// The backing value.
	private var storedValue: Value
	
	/// A reference to the shadow graph.
	private var backReference: BackReference?	// FIXME: Property is never set!
	private struct BackReference : Sendable {
		let shadow: UntypedShadow
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
