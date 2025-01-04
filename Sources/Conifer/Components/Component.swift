// Conifer © 2019–2025 Constantino Tsarouhas

/// A node in a domain-specific tree, managed and tracked by Conifer.
///
/// Components represent domain-specific elements, e.g., paragraphs, views, or (sub)computations, or collections thereof. Conifer clients should specialise this protocol to domain-specific types and restrict `Body` to conform to that protocol. For example, a web application framework that works with elements could define the following protocol:
///
/// 	public protocol Element : Component where Body : Element {}
///
/// Components are assembled using other components, by implementing the `body` property and returning the component's content. Conifer provides several foundational component types that are produced in component builders.
///
/// Do not access the `body` property directly. Access and traverve a component using its shadow, e.g., `makeShadow(over: component).property` instead of `component.property`. Conifer ensures that external dependencies are resolved and lazily renders parts of the traversed component.
///
/// Component values can be configured but are stateless by themselves. State should be stored externally (like an object graph) and accessed via property wrappers conforming to `DynamicProperty`. Dynamic properties are only valid during rendering, e.g., within `body`'s getter.
public protocol Component : Sendable {
	
	/// The component's body.
	///
	/// The system invokes this property's getter during rendering. The system invalidates the body whenever any dynamic property changes.
	///
	/// Any thrown errors cause rendering to fail. Conifer currently does not support intercepting errors.
	///
	/// - Precondition: Dynamic properties on `self` are updated and valid.
	///
	/// - Warning: This property shouldn't be accessed directly by components. Access components through its shadow, e.g., `makeShadow(over: component)` or via a containing component's shadow. Accessing this property on a foundational component results in a runtime error.
	///
	/// - Warning: Do not access mutable storage or external sources directly from within this property's getter, but instead use appropriate property wrappers which conform to `DynamicProperty` or bindings to such properties. Any accesses to storage or external sources that does not go through such property wrappers or bindings cannot be tracked by the shadow graph and may cause staleness issues.
	@ComponentBuilder
	var body: Body { get async throws }
	
	/// A component that represents the contents of an instance of `Self`.
	associatedtype Body : Component
	
}
