// Conifer © 2019–2023 Constantino Tsarouhas

/// A property whose lifetime is shared with the component's shadow.
///
/// State properties can be used in component and dynamic property types.
@propertyWrapper
public struct State<Value> : DynamicProperty {
	
	/// Creates a state property with given inital value.
	public init(wrappedValue: Value) {
		self.wrappedValue = wrappedValue
	}
	
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
		
		get {
			TODO.unimplemented
		}
		
		nonmutating set {
			TODO.unimplemented
		}
		
	}
	
	// See protocol.
	public actor Dependency : Conifer.Dependency {
		
		// See protocol.
		public nonisolated var changes: some AsyncSequence {
			AsyncStream<()> { c in
				TODO.unimplemented
			}
		}
		
	}
	
}
