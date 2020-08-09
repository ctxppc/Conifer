// Conifer © 2019–2020 Constantino Tsarouhas

import DepthKit

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
	/// The system invokes this method whenever the component's associated element in the shadow graph needs to be created or updated, e.g., after one of its dependencies has changed.
	///
	/// This method has a default implementation that renders `body` directly, which is appropriate for light components.
	///
	/// Any elements in `graph` that are accessed within this method are recorded as dependencies whereas any changed elements are recorded as dependents. Any declared contextual properties are also recorded as dependencies. Implementations of this method must ensure that do not create any cyclical dependencies.
	///
	/// - Parameter graph: The shadow graph to update.
	/// - Parameter parentPath: The path in `graph` to the parent of the shadow element representing `self`.
	func update(_ graph: inout ShadowGraph<ShadowElement>, at parentPath: ShadowGraphLocation)
	
	/// The type of values representing instances of `Self` in the shadow graph.
	associatedtype ShadowElement : Conifer.ShadowElement
	
}

extension Component {
	
	public func update(_ graph: inout ShadowGraph<ShadowElement>, at parentPath: ShadowGraphLocation) {
		TODO.unimplemented
	}
	
}
