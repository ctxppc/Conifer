// Conifer © 2019–2024 Constantino Tsarouhas

/// A node in a domain-specific tree, managed and tracked by Conifer.
///
/// Components represent domain-specific elements, e.g., paragraphs, views, or (sub)computations, or collections thereof. Conifer clients should specialise this protocol to domain-specific types and restrict `Body` to conform to that protocol. For example, a web application framework that works with elements could define the following protocol:
///
/// 	public protocol Element : Component where Body : Element {}
///
/// Components are assembled using other components, by implementing the `body` property and returning the component's content. Conifer provides several foundational component types that are produced in component builders.
///
/// Do not access the `body` property directly. Access and traverve a component using its shadow, e.g., `Shadow(of: component).myProperty` instead of `component.property`. Conifer ensures that external dependencies are resolved and lazily renders parts of the traversed component.
///
/// Component values can be configured but are stateless by themselves. State should be stored externally (like an object graph) and accessed via property wrappers conforming to `DynamicProperty`.
public protocol Component : Sendable {
	
	/// The component's body.
	///
	/// The system invokes this property's getter during rendering after populating or updating all dynamic properties on `self`. The system invalidates the body whenever any dynamic property's value changes.
	///
	/// - Warning: This property shouldn't be accessed directly by components. Access components through its shadow, e.g., `Shadow(of: component)` or via a containing component's shadow. Accessing this property on a foundational component results in a runtime error.
	///
	/// - Warning: Do not access mutable storage or external sources directly from within this property's getter, but instead use appropriate property wrappers which conform to `DynamicProperty` or bindings to such properties. Any accesses to storage or external sources that does not go through such property wrappers or bindings cannot be tracked by the shadow graph and may cause staleness issues.
	@ComponentBuilder
	var body: Body { get async throws }
	
	/// A component that represents the contents of an instance of `Self`.
	associatedtype Body : Component
	
}

extension Component {
	
	/// Creates a shadow over `self` with a given graph and a given location on the graph.
	///
	/// - Parameters:
	///   - graph: The graph.
	///   - location: The location of `self` in `graph`.
	///
	/// - Requires: `graph[location]` is equal to `self`. This also implies that `location` refers to a rendered component in `graph`.
	func makeShadow(graph: ShadowGraph, location: ShadowLocation) -> some Shadow<Self> {
		ShadowType(graph: graph, location: location)
	}
	
	/// Creates an untyped shadow over `self` with a given graph and a given location on the graph.
	///
	/// - Parameters:
	///   - graph: The graph.
	///   - location: The location of `self` in `graph`.
	///
	/// - Requires: `graph[location]` is equal to `self`. This also implies that `location` refers to a rendered component in `graph`.
	func makeUntypedShadow(graph: ShadowGraph, location: ShadowLocation) -> some Shadow {
		ShadowType<Self>(graph: graph, location: location)
	}
	
}
