// Conifer © 2019–2021 Constantino Tsarouhas

/// A value that describes zero or more domain-specific artefacts.
///
/// Components represent domain-specific elements, e.g., paragraphs, views, or (sub)computations. Conifer clients should specialise this protocol to domain-specific types and restrict `Body` to conform to that protocol. For example, a web application framework that works with elements could define the following protocol:
///
/// 	public protocol Element : Component where Body : Element {}
///
/// Most components are assembled using other components, by implementing the `body` property and returning the component's content. More foundational components can implement the `render(in:context:)` method instead. This method is usually reserved for Conifer clients and not recommended for clients building on top of a Conifer client.
///
/// Every component is rendered as an *artefact*, which is a value organised in a tree structure called the *shadow graph*. An artefact itself consists of zero or more subtrees of vertices, which are embedded in the artefacts' tree structure to form the render output.
public protocol Component {
	
	/// The component's body.
	///
	/// A component can access dynamic properties declared on `Self` during rendering, i.e., during an invocation of this property's getter. The system invalidates the body whenever any dynamic property's value changes.
	///
	/// - Note: This property shouldn't be accessed by components.
	///
	/// - Warning: Do not access mutable storage or external sources directly from within this property's getter, but instead use appropriate property wrappers which conform to `DynamicProperty` or bindings to such properties. Any accesses to storage or external sources that does not go through such property wrappers or bindings cannot be tracked by the shadow graph and may cause staleness issues.
	var body: Body { get }
	
	/// A component that acts as the body of instances of `Self`.
	associatedtype Body : Component where Body.Artefact == Artefact, Body.Context == Context
	
	/// Renders the artefact described by `self` into `graph`.
	///
	/// The system invokes this method when the artefact associated with this component needs to be configured or reconfigured. The component can invoke `produce(_:)` and `render(_:)` to produce artefacts or render subcomponents at the graph location reserved for `self`. The component can also traverse the graph and produce artefacts or render components at other locations in the graph.
	///
	/// Similar to `body`, a component can access dynamic properties declared on `Self` during rendering, i.e., during the invocation of this method.
	///
	/// The resulting artefact is cached by the shadow graph until this component is invalidated. That is, until `self` is invalidated, any subsequent invocations of `render(_:)` where `self` is being rendered by its containing component do not cause `render(in:context:)` to be invoked on `self`. Instead, the shadow graph inserts the previously rendered artefact.
	///
	/// To determine when to invalidate a component, a shadow graph carefully monitors accesses during the `render(in:context:)` call and registers the accessed values or resources as dependencies of the component being rendered. The following direct and indirect accesses are monitored and may cause an invalidation:
	/// * If `self` accesses any artefact produced by another component, `self` is invalidated if that other component is also invalidated.
	/// * If `self` accesses a dynamic property, `self` is invalidated if that dynamic property is also invalidated.
	///
	/// The default implementation directly renders `body`. In most cases, the default implementation is sufficient and recommended.
	///
	/// - Note: This method shouldn't be invoked by components. To render a subcomponent, invoke `render(_:)` on `graph` instead, passing the subcomponent.
	///
	/// - Warning: Do not access mutable storage or external sources directly from within this method, but instead use appropriate property wrappers which conform to `DynamicProperty`. Any accesses to storage or external sources that does not go through such property wrappers cannot be tracked by the shadow graph and may cause cache staleness issues.
	///
	/// - Parameter graph: The shadow graph to render the component's artefacts in.
	/// - Parameter location: The artefact's location.
	func render(in graph: inout ShadowGraph<Artefact>, at location: ShadowGraphLocation) async
	
	/// A value representing an instance of `Self` in a shadow graph.
	associatedtype Artefact : Conifer.Artefact
	
}

extension Component {
	public func render(in graph: inout ShadowGraph<Artefact>, at location: ShadowGraphLocation, context: Context) async {
		graph.render(body, at: location, context: context)
	}
}
