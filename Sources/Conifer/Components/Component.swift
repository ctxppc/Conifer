// Conifer © 2019–2021 Constantino Tsarouhas

/// A value that describes zero or more domain-specific artefacts.
///
/// Components represent domain-specific elements, e.g., paragraphs, views, or (sub)computations, or collections thereof. Conifer clients should specialise this protocol to domain-specific types and restrict `Body` to conform to that protocol. For example, a web application framework that works with elements could define the following protocol:
///
/// 	public protocol Element : Component where Body : Element {}
///
/// Most components are assembled using other components, by implementing the `body` property and returning the component's content. More foundational components can implement the `render(in:at:)` method instead. This method is usually reserved for Conifer clients and not recommended for clients building on top of a Conifer client.
///
/// Every component renders itself into zero or more *artefacts*, which are values organised in a tree structure called the *artefact graph*. The product of a render pass is the artefact graph resulting from rendering a root component and its descendants, and may be used directly (e.g., a DOM tree in a web framework) or processed further (e.g., a computation tree that doesn't represent a final computation).
///
/// When a component is rendered for the first time, the system stores the component in a shadow graph where it also records any dependencies the component might have. When a component is re-rendered, the system first checks whether the component's dependencies have changed. If they did not, rendering is skipped and the system retains the artefacts from the previous rendering pass.
///
/// Component values can be configured but are stateless by themselves. State should be stored externally (like an object graph) and accessed via property wrappers conforming to `DynamicProperty`.
public protocol Component {
	
	/// The component's body.
	///
	/// A component can access dynamic properties declared on `Self` during rendering, i.e., during an invocation of this property's getter. The system invalidates the body whenever any dynamic property's value changes.
	///
	/// - Note: This property shouldn't be accessed directly by components. To render a component as part of a parent component, include it as part of the parent component's `body` or render it in the shadow graph as part of the parent component's `render(in:at:)` implementation.
	///
	/// - Warning: Do not access mutable storage or external sources directly from within this property's getter, but instead use appropriate property wrappers which conform to `DynamicProperty` or bindings to such properties. Any accesses to storage or external sources that does not go through such property wrappers or bindings cannot be tracked by the shadow graph and may cause staleness issues.
	var body: Body { get }
	
	/// A component that acts as the body of instances of `Self`.
	associatedtype Body : Component where Body.Artefact == Artefact
	
	/// Renders the artefacts described by `self` into `graph`.
	///
	/// The system invokes this method when the artefacts associated with this component need to be configured or reconfigured. The component can invoke `produce(_:at:)` and `render(_:at:)` to produce artefacts or render subcomponents at the graph location reserved for `self`. The component can also traverse the graph and produce artefacts or render components at other locations in the graph.
	///
	/// Similar to `body`, a component can access dynamic properties declared on `Self` during rendering, i.e., during the invocation of this method.
	///
	/// The resulting artefacts are cached by the shadow graph until this component is invalidated. That is, until the artefacts produced by `self` are invalidated, any subsequent invocations of `render(_:)` where `self` is being rendered by its containing component do not cause `render(in:at:)` to be invoked on `self`. Instead, the shadow graph inserts the previously rendered artefacts.
	///
	/// To determine when to invalidate a component's produced artefacts, a shadow graph carefully monitors accesses during the `render(in:at:)` call and registers the accessed values or resources as dependencies of the component being rendered. The following direct and indirect accesses are monitored and may cause an invalidation:
	/// * If `self` accesses an artefact produced by another component, `self`'s artefacts are invalidated when that other component's artefact is also invalidated.
	/// * If `self` accesses a dynamic property, `self` is invalidated when that dynamic property is also invalidated.
	///
	/// The default implementation directly renders `body` at `location`. In most cases, the default implementation is sufficient and recommended.
	///
	/// - Note: This method is intended for use by shadow graphs only and shouldn't be invoked by components. To render a subcomponent, invoke `render(_:)` on `graph` instead, passing the subcomponent.
	///
	/// - Warning: Do not access mutable storage or external sources directly from within this method, but instead use appropriate property wrappers which conform to `DynamicProperty`. Any accesses to storage or external sources that does not go through such property wrappers cannot be tracked by the shadow graph and may cause cache staleness issues.
	///
	/// - Parameter graph: The shadow graph to render the component's artefacts in.
	/// - Parameter location: The proposed location for the artefacts to produce.
	func render(in graph: inout ShadowGraph<Artefact>, at location: ShadowGraphLocation) async
	
	/// A value representing an instance of `Self` in a shadow graph.
	associatedtype Artefact : Conifer.Artefact
	
}

extension Component {
	public func render(in graph: inout ShadowGraph<Artefact>, at location: ShadowGraphLocation) async {
		graph.render(body, at: location)
	}
}

extension Component where Body == Never<Artefact> {
	
	@available(*, unavailable, message: "render(in:at:) must be implemented in components without body.")
	public func render(in graph: inout ShadowGraph<Artefact>, at location: ShadowGraphLocation) async {
		fatalError("render(in:at:) must be implemented in components without body.")
	}
	
}
