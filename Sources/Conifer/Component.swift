// Conifer © 2019–2020 Constantino Tsarouhas

import DepthKit

/// A value that describes zero or more nodes in a realisation tree.
///
/// Components can be defined by either providing a body in the `body` property or by implementing the `update(node:context:)` method.
public protocol Component {
	
	/// The type of the component's body.
	associatedtype Body : Component
	
	/// The component's body.
	var body: Body { get }
	
	/// Updates the node associated with this component.
	func update(node: Node, context: Context)
	
}

extension Never : Component {
	
	public var body: Never {
		fatalError("Component does not have a body")
	}
	
	public func update(node: Node, context: Context) {
		fatalError("Component does not have a body")
	}
	
}

extension Component where Body == Never {
	
	public func update(node: Node, context: Context) {
		TODO.unimplemented
	}
	
}
