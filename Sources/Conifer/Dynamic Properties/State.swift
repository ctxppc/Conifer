// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit

/// A dynamic property whose lifetime is shared with the component's shadow.
///
/// When a component is rendered, Conifer updates each `State` value used as a property wrapper in the component value or in any of its dynamic properties with
@propertyWrapper
public struct State<Value : Sendable> : MutableDynamicProperty {
	
	/// Creates a state property with given initial value.
	public init(wrappedValue: Value) {
		self.storedValue = wrappedValue
	}
	
	// See protocol.
	public mutating func update<Component>(for shadow: some Shadow<Component>, keyPath: Self.KeyPath<Component>) async {
		
		// If state container already has a value, replace the initial value.
		if let value: Value = await shadow.element(ofType: StateContainer.self)?[keyPath] {
			storedValue = value
		}
		
		// Establish a back reference for sending updated values.
		backReference = .init(shadow: shadow, keyPath: keyPath)
		
	}
	
	// See protocol.
	public var wrappedValue: Value {
		storedValue
	}
	
	// See protocol.
	public func send(updatedValue: Value) {
		guard let backReference else { preconditionFailure("Cannot update @State property outside of a rendering context") }
		Task { [updatedValue] in
			await backReference.shadow.update(StateContainer.self) {
				with($0 ?? .init()) {
					$0[backReference.keyPath] = updatedValue
				}
			}
		}
	}
	
	/// The backing value.
	private var storedValue: Value
	
	/// A reference to the shadow graph for sending updated values.
	private var backReference: BackReference?
	private struct BackReference : @unchecked Sendable {	// Conifer only provides sendable key paths
		let shadow: any Shadow
		let keyPath: AnyKeyPath
	}
	
}

/// A mapping of state properties to their values for a component.
private struct StateContainer : @unchecked Sendable {	// Conifer only provides sendable key paths
	
	/// Accesses a value in the state container.
	subscript <Value : Sendable>(keyPath: AnyKeyPath) -> Value? {
		
		get {
			guard let value = valuesByKeyPath[keyPath] else { return nil }
			return value as? Value !! "Expected state value of type \(Value.self); got \(value) instead"
		}
		
		set {
			valuesByKeyPath[keyPath] = newValue
		}
		
	}
	
	/// The container's storage.
	private var valuesByKeyPath = [AnyKeyPath : any Sendable]()
	
}
