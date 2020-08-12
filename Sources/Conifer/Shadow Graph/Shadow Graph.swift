// Conifer © 2019–2020 Constantino Tsarouhas

import DepthKit

/// A data structure consisting of elements rendered by components.
///
/// A shadow graph consists of two two intertwined graphs: an element tree starting from a root element (usually rendered by the root component) and a directional acyclic dependency graph. When a component is rendered, the system invokes the component's `update(_:at:)` method, passing a graph and a location
public struct ShadowGraph<Element : ShadowElement> {
	
	/// The graph's elements, keyed by location.
	private var elementsByLocation = [ShadowGraphLocation : Element]()
	
	/// Accesses the element at given location.
	///
	/// - Note: This subscript creates a dependency on the complete element. To create a more fine-grained dependency, use `subscript(_:)` to access the element through a proxy instead.
	public subscript (elementAt location: ShadowGraphLocation) -> Element {
		mutating get {
			addDependency(.full, onElementAt: location)
			return elementsByLocation[location] !! "Invalid graph location"
		}
		set { elementsByLocation[location] = newValue }
	}
	
	/// Accesses the element at given location through a proxy.
	///
	/// The proxy records all accessed key paths as dependencies.
	public subscript (location: ShadowGraphLocation) -> ElementProxy {
		get { .init(element: elementsByLocation[location] !! "Invalid graph location") }
		set {
			addDependency(.keyPaths(newValue.accessedKeyPaths), onElementAt: location)
			elementsByLocation[location] = newValue.element
		}
	}
	
	/// A value that allows fine-grained access to a shadow element's properties.
	@dynamicMemberLookup
	public struct ElementProxy {
		
		/// Creates a proxy for given element.
		fileprivate init(element: Element) {
			self.element = element
		}
		
		/// The element being proxied.
		fileprivate var element: Element
		
		/// The key paths that have been accessed.
		fileprivate private(set) var accessedKeyPaths = Set<PartialKeyPath<Element>>()
		
		/// Accesses the value at given key path on the proxied element.
		public subscript <Value>(dynamicMember keyPath: WritableKeyPath<Element, Value>) -> Value {
			
			mutating get {
				accessedKeyPaths.insert(keyPath)
				return element[keyPath: keyPath]
			}
			
			set {
				accessedKeyPaths.insert(keyPath)
				element[keyPath: keyPath] = newValue
			}
			
		}
		
	}
	
	/// Adds given dependency on the element in the graph at given location.
	///
	/// - Parameter dependency: The dependency on the element to add.
	/// - Parameter location: The location of the element in the graph.
	private mutating func addDependency(_ dependency: Dependency, onElementAt location: ShadowGraphLocation) {
		dependenciesByLocation[location, default: .init()].formUnion(with: dependency)
	}
	
	/// The element dependencies, keyed by location.
	private var dependenciesByLocation = [ShadowGraphLocation : Dependency]()
	
	/// A dependency on an element in the graph.
	private enum Dependency {
		
		/// Creates an empty dependency.
		init() {
			self = .keyPaths([])
		}
		
		/// A dependency on the values at `keyPaths` on the element.
		case keyPaths(_ keyPaths: Set<PartialKeyPath<Element>>)
		
		/// A whole-element dependency on the element.
		case full
		
		/// Unites the dependency from `self` and `other`.
		mutating func formUnion(with other: Dependency) {
			switch (self, other) {
				case let (.keyPaths(a), .keyPaths(b)):	self = .keyPaths(a.union(b))
				case (.full, _), (_, .full):			self = .full
			}
		}
		
	}
	
}
