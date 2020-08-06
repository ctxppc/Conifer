// Conifer © 2019–2020 Constantino Tsarouhas

import DepthKit

extension Never : Component {
	
	public var body: Never {
		fatalError("Component does not have a body")
	}
	
	// See protocol.
	public func update(node: Node, context: Context) {
		fatalError("Component does not have a body")
	}
	
}
