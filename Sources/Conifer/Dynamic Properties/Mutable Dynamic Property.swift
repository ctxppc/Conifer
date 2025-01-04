// Conifer © 2019–2025 Constantino Tsarouhas

/// A dynamic property that can be updated from within a component.
public protocol MutableDynamicProperty : DynamicProperty where Value : Sendable {
	
	/// Sends given value to the source of truth, requesting it be updated.
	///
	/// As `wrappedValue` can only change between rendering cycles, `wrappedValue` is unchanged immediately after this method returns. It might be equal to `value` in the next rendering cycle.
	///
	/// - Precondition: `self` has been updated, i.e., `update(for:keyPath:)` has been invoked.
	func send(updatedValue: Value)
	
	/// A binding to this property.
	var projectedValue: Binding<Value> { get }
	
}

extension MutableDynamicProperty {
	public var projectedValue: Binding<Value> {
		.init(get: { wrappedValue }, send: send)
	}
}
