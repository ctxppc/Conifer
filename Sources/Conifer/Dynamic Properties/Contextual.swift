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
	public func makeDependency(forComponentAt location: Location, propertyIdentifier: some Hashable) -> Dependency {
		TODO.unimplemented
	}
	
	// See protocol.
	public func update(dependency: Dependency, change: Dependency.Change?) async throws {
		TODO.unimplemented
	}
	
	// See protocol.
	public var wrappedValue: Value {
		storedValue !! "Accessing \(keyPath) outside rendering context"
	}
	
	/// The contextual value, or `nil` if the dependent component isn't being rendered yet.
	@State
	private var storedValue: Value?
	
	public actor Dependency : Conifer.Dependency {
		
		public nonisolated var changes: some AsyncSequence {
			AsyncStream<()> { c in
				TODO.unimplemented
			}
		}
		
	}
	
}
