// Conifer © 2019–2023 Constantino Tsarouhas

import DepthKit

/// A dynamic property whose value is provided by an ancestor component.
///
/// Accessing a contextual value that is not specified by an ancestor is not permitted.
@propertyWrapper
public struct Contextual<Value> : DynamicProperty {
	
	/// Creates a contextual property.
	///
	/// - Parameter keyPath: The keypath from a context to the contextual value.
	public init(_ keyPath: KeyPath<Context, Value>) {
		self.keyPath = keyPath
	}
	
	/// The keypath from a context to the contextual value.
	let keyPath: KeyPath<Context, Value>
	
	// See protocol.
	public func makeDependency<C : Component>(
		forComponentAt location:	Location,
		propertyAt propertyKeyPath:	KeyPath<C, Self>
	) -> Dependency {
		TODO.unimplemented
	}
	
	@available(*, unavailable, message: "Dynamic properties are only available in components")
	public var wrappedValue: Value {
		preconditionFailure("@\(Self.self) is only available in components")
	}
	
	// See protocol.
	public func value(dependency: Dependency, change: Dependency.Change?) async throws -> Value {
		TODO.unimplemented
	}
	
	public actor Dependency : Conifer.Dependency {
		
		public nonisolated var changes: some AsyncSequence {
			AsyncStream<()> { c in
				TODO.unimplemented
			}
		}
		
	}
	
}
