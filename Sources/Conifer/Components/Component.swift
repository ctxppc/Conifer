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
	associatedtype Body : Component
	
	/// Updates the shadow graph.
	///
	/// This method has a default implementation that delegates to `body`, which is appropriate for light components. This method is invoked by the shadow graph the first time this component is rendered as well as whenever a transaction affects this component or component's context.
	///
	/// Any elements in `graph` that are accessed within this method are recorded as dependencies whereas any changed elements are recorded as dependents. Any declared contextual properties are also recorded as dependencies.
	///
	/// - Parameter graph: The shadow graph to update.
	/// - Parameter parentPath: The path in `graph` to the shadow element whose component declares `self`.
	func update(_ graph: inout ShadowGraph, at parentPath: ShadowPath)
	
}

extension Component {
	
	public func update(_ graph: inout ShadowGraph, at parentPath: ShadowPath) {
		TODO.unimplemented
	}
	
}
