// Conifer © 2019–2024 Constantino Tsarouhas

/// A node in a domain-specific tree, managed and tracked by Conifer.
///
/// Components represent domain-specific elements, e.g., paragraphs, views, or (sub)computations, or collections thereof. Conifer clients should specialise this protocol to domain-specific types and restrict `Body` to conform to that protocol. For example, a web application framework that works with elements could define the following protocol:
///
/// 	public protocol Element : Component where Body : Element {}
///
/// Components are assembled using other components, by implementing the `body` property and returning the component's content. Conifer provides several foundational component types that are produced in component builders.
///
/// Do not access the `body` property directly. Traverve a component using its shadow, e.g., `Shadow(of: component).myProperty` instead of `component.property`. Conifer ensures that external dependencies are resolved and lazily renders parts of the traversed component.
///
/// Component values can be configured but are stateless by themselves. State should be stored externally (like an object graph) and accessed via property wrappers conforming to `DynamicProperty`.
public protocol Component : Sendable {
	
	/// The component's body.
	///
	/// A component can access dynamic properties declared on `Self` during rendering, i.e., during an invocation of this property's getter. The system invalidates the body whenever any dynamic property's value changes.
	///
	/// - Warning: This property shouldn't be accessed directly by components. Access components through its shadow, e.g., `Shadow(of: component)` or via a containing component's shadow. Accessing this property in a foundational component type results in a runtime error.
	///
	/// - Warning: Do not access mutable storage or external sources directly from within this property's getter, but instead use appropriate property wrappers which conform to `DynamicProperty` or bindings to such properties. Any accesses to storage or external sources that does not go through such property wrappers or bindings cannot be tracked by the shadow graph and may cause staleness issues.
	@ComponentBuilder
	var body: Body { get async throws }
	
	/// A component that acts as the body of instances of `Self`.
	associatedtype Body : Component
	
}
