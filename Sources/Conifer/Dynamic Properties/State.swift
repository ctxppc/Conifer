// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit

/// A dynamic property whose lifetime is shared with the component's shadow.
///
/// When a component is rendered, Conifer updates each `State` value used as a property wrapper in the component value or in any of its dynamic properties with
@propertyWrapper
public struct State<Value> : DynamicProperty {
	
	/// Creates a state property with given inital value.
	public init(wrappedValue: Value) {
		self.wrappedValue = wrappedValue
	}
	
	/// Terminates the program.
	///
	/// `@State` properties are backed by a shadow graph and therefore do not have dependencies of their own.
	public func makeDependency(forComponentAt location: Location, propertyIdentifier: some Hashable) -> Dependency {
		fatalError("State properties cannot have dependencies")
	}
	
	/// Terminates the program.
	///
	/// `@State` properties are backed by a shadow graph and therefore do not support change tracking.
	public func update(dependency: Dependency, change: Dependency.Change?) async throws {
		fatalError("State properties do not support change tracking")
	}
	
	/// A reference to the shadow graph for the value of `self`, or `nil` if `self` hasn't been populated yet.
	///
	/// When rendering a component, Conifer updates this property to ensure that any reads and writes of `wrappedValue` are done on the correct shadow component, even when `self` is copied, e.g., by a closure.
	var graphReference: GraphReference?
	struct GraphReference {
		
		/// The shadow graph managing the state property.
		let shadowGraph: ShadowGraph
		
		/// The location of the component.
		let location: Location
		
		/// The identifier of the state property.
		let propertyDefinition: PropertyDefinition
		
	}
	
	// See protocol.
	public var wrappedValue: Value {
		
		get {
			let graphReference = graphReference !! "@State property has not been populated yet; dynamic properties can only be accessed from within a rendering context"
			return graphReference.shadowGraph.assumeIsolated { shadowGraph in
				guard let container: StateContainer = shadowGraph[graphReference.location] else {
					preconditionFailure("No state container available for \(graphReference)")
				}
				return container[graphReference.propertyDefinition]
			}
		}
		
		nonmutating set {
			let graphReference = graphReference !! "@State property has not been populated yet; dynamic properties can only be accessed from within a rendering context"
			graphReference.shadowGraph.assumeIsolated { shadowGraph in
				shadowGraph[graphReference.location, default: StateContainer()][graphReference.propertyDefinition] = newValue
			}
		}
		
	}
	
	// See protocol.
	public actor Dependency : Conifer.Dependency {
		
		/// Terminates the program.
		@available(*, unavailable)
		public init() {
			fatalError("State properties cannot have dependencies")
		}
		
		// See protocol.
		public nonisolated var changes: AsyncStream<()> {
			fatalError("State properties cannot have dependencies")
		}
		
	}
	
}
