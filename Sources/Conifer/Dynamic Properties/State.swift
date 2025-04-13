// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

/// A dynamic property whose lifetime is shared with the component's shadow.
@propertyWrapper
public struct State<Value : Sendable> : MutableDynamicProperty {
	
	/// Creates a state property with given initial value.
	public init(wrappedValue: Value) {
		self.storedValue = wrappedValue
	}
	
	// See protocol.
	public mutating func update<Component>(for shadow: some Shadow<Component>, keyPath: Path<Component>) async {
		
		// If state container already has a value, replace the initial value.
		if let value: Value = await shadow.stateContainer[keyPath] {
			storedValue = value
		}
		
		// Establish a back reference for sending updated values.
		let shadow = UnownedShadow(shadow)
		_send = { updatedValue in
			Task {
				try! await shadow.update(\.stateContainer) {	// FIXME: Handle error
					$0[keyPath] = updatedValue
				}
			}
		}
		
	}
	
	// See protocol.
	public var wrappedValue: Value {
		storedValue
	}
	
	// See protocol.
	public func send(updatedValue: Value) {
		let send = _send !! "Cannot update @State property outside of a rendering context"
		send(updatedValue)
	}
	
	/// The backing value.
	private var storedValue: Value
	
	private var _send: Sender?
	private typealias Sender = @Sendable (Value) -> ()
	
}

fileprivate extension ShadowSnapshot {
	var stateContainer: StateContainer {
		get { self[\.stateContainer] ?? .init() }
		set { self[\.stateContainer] = newValue }
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
