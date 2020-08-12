// Conifer © 2019–2020 Constantino Tsarouhas

/// A value that describes zero or more elements in the shadow graph.
///
/// Components represent domain-specific elements, e.g., paragraphs, views, or (sub)computations. Conifer clients should specialise this protocol to domain-specific types and restrict `Body` to conform to that protocol. For example, a web application framework that works with elements could define the following protocol:
///
/// 	protocol Element : Component where Body : Element {}
///
/// Components can be defined by either providing a body in the `body` property or by implementing the `update(_:at:)` method. The latter is a foundational method, usually reserved for Conifer clients.
///
/// Dynamic properties, properties whose values conform to `ExternalProperty` such as `Contextual`, can be declared and used within `Component`. The system automatically fulfills these external dependencies before rendering the component.
public protocol Component {
	
	/// The component's body.
	///
	/// The component has access to contextual properties declared in `self`. The system recomputes the body whenever any contextual property's value changes.
	var body: Body { get }
	
	/// The type of the component's body.
	associatedtype Body : Component where Body.ShadowElement == ShadowElement
	
	/// Updates the shadow graph.
	///
	/// The system invokes this method whenever the component's associated elements in the shadow graph need to be created or updated. The system proposes a location `proposedLocation`, usually a location within the parent component, where the component's element is expected. In most cases, a component creates or updates the element at this location. A component may create or update elements at other locations, in addition to or or instead of the element at `proposedLocation`. For example, a group component may create multiple successive elements, with the first one at `proposedLocation`.
	///
	/// Any elements created or updated within this method are associated to `self`. The system automatically deletes these elements (and any descendants) if `self` is removed from the component hierarchy, i.e., if the parent component no longer renders `self`. The component cannot update or delete elements that are not associated to `self`.
	///
	/// The shadow graph also contains a dependency graph. Any elements not associated to `self` that are accessed in this method are recorded as dependencies of the component. If any such dependency changes at any point in the future, the system schedules an update pass for `self`, causing this method to be invoked again. Care must be taken to avoid cyclical dependencies; the system limits the number of update passes per transaction per component.
	///
	/// - Note: This method has a default implementation that renders `body` directly, which is appropriate for light components. Implementing this method enables manipulating the shadow graph in ways that are not possible or easy with a hierarchy of components. However, care must be taken to avoid creating cyclical dependencies that can cause the rendering process to fail or to behave indeterministically.
	///
	/// - Parameter graph: The shadow graph to update.
	/// - Parameter proposedLocation: The location in `graph` where the component's element is expected.
	/// - Parameter context: The value produced by `self` during the last update pass, or `nil` if the component is being rendered for the first time.
	///
	/// - Returns: A value encapsulating any information required during a future update pass.
	func update(_ graph: inout ShadowGraph<ShadowElement>, at proposedLocation: ShadowGraphLocation, context: UpdateContext?) -> UpdateContext
	
	/// An element of the shadow graph, described by an instance of `Self`.
	associatedtype ShadowElement : Conifer.ShadowElement
	
	/// A value that an instance of `Self` can store & retrieve during updates.
	associatedtype UpdateContext = ()
	
}

extension Component where UpdateContext == () {
	
	public func update(_ graph: inout ShadowGraph<ShadowElement>, at parentPath: ShadowGraphLocation, context: ()?) {
		TODO.unimplemented
	}
	
}
