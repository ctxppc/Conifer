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
	
	/// The type of nodes represented by instances of `Self`.
	associatedtype Node
	
	/// Updates the node associated with this component.
	///
	/// This method has a default implementation that delegates to `body`, which is appropriate for light components. Clients of a Conifer library or framework should not override this method unless explicitly recommended by the library, and instead implement the `body` property.
	func update(node: Node, context: Context)
	
}

extension Component where Body == Never {
	
	// See protocol.
	public func update(node: Node, context: Context) {
		TODO.unimplemented
	}
	
}
