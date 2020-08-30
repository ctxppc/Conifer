// Conifer © 2019–2020 Constantino Tsarouhas

/// A value that describes zero or more domain-specific artefacts.
///
/// Components represent domain-specific elements, e.g., paragraphs, views, or (sub)computations. Conifer clients should specialise this protocol to domain-specific types and restrict `Body` to conform to that protocol. For example, a web application framework that works with elements could define the following protocol:
///
/// 	protocol Element : Component where Body : Element {}
///
/// Most components are assembled using other components, by implementing the `body` property and returning the component's content. The system automatically renders these *lightweight* components.
///
/// Components can be defined by either providing a body in the `body` property or by implementing the `makeArtefacts(context:)` method. The latter is a foundational method, usually reserved for Conifer clients.
///
/// Dynamic properties, properties whose values conform to `DynamicProperty` such as `Environmental`, can be declared and used within `body` and `makeArtefacts(context:)`. The system automatically fulfills these external dependencies before rendering the component.
public protocol Component {
	
	/// The component's body.
	///
	/// The component can access dynamic properties declared on `Self`. The system invalidates the body whenever any dynamic property's value changes.
	var body: Body { get }
	
	/// A component that acts as the body of instances of `Self`.
	associatedtype Body : Component where Body.Artefact == Artefact, Body.Context == Context
	
	/// Renders the artefacts described by `self`.
	///
	/// The system invokes this method whenever the artefacts associated with the component need to be created or updated. The produced artefacts are cached in the shadow graph and invalidated when the context or environment changes.
	///
	/// The component can access dynamic properties declared on `Self`. The system invalidates the component's artefacts whenever any dynamic property's value changes.
	///
	/// The default implementation renders `body` directly. In most cases, the default implementation is sufficient and recommended.
	///
	/// - Parameter graph: The shadow graph to render the component's artefacts in.
	/// - Parameter context: A value provided by the component rendering `self`.
	func render(in graph: ShadowGraph<Artefact>, context: Context)
	
	/// A value provided by a container component when rendering an instance of `Self`.
	associatedtype Context
	
	/// A value produced when rendering an instance of `Self`.
	associatedtype Artefact
	
}

extension Component {
	
	public func render(in graph: ShadowGraph<Artefact>, context: Context) {
		TODO.unimplemented
	}
	
}
