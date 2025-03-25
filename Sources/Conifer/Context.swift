// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

/// A container of values propagated through a component hierarchy.
///
/// The context of a component is set up by its ancestor components. It is a mechanism by which information can flow from parent component to child components without having to define a property for every possible piece of information that needs to flow downwards.
///
/// ## `@Contextual` Properties
///
/// Contexts are prominently visible via `@Contextual` properties and the `context(_:_:)` modifier method. A parent component can assign a contextual property using the modifier; a descendant component can then access this value via a contextual property.
///
/// 	struct Document : Component {
///			var body: some Component {
///				WelcomeText()
///					.context(\.firstName, "Jake")
///			}
/// 	}
///
/// 	struct WelcomeText : Component {
///
///			@Contextual(\.firstName)
///			private var name
///
///			var body: some Component {
///				Text("Welcome, \(name)!")
///			}
///
/// 	}
///
/// To declare a contextual property such as `firstName` in the example above, declare a property in an extension of this type and return `self[keyPath]` in the getter where `keyPath` is the key path of the new property. Conifer manages the property's storage.
///
///		extension Context {
///			var firstName: String {
///				self[\.firstName]
///			}
///		}
///
/// Prefer contextual properties above ordinary properties when propagation makes sense, like a database connection or a font size.
public struct Context : Sendable {
	
	/// Creates an empty context.
	init() {}
	
	/// The contextual values.
	private var values = [AnyKey : any Sendable]()
	private typealias AnyKey = PartialKeyPath<Self> & Sendable
	public typealias Key<Value> = WritableKeyPath<Self, Value> & Sendable where Value : Sendable
	
	/// Accesses the contextual value at a given key.
	public subscript <Value>(key: Key<Value>) -> Value {
		get { (values[key as AnyKey] !! "\(key) not available in context (\(self))") as! Value }
		set { values[key as AnyKey] = newValue }
	}
	
	/// Returns a copy of `self` after replacing any assignments contained in a given context.
	consuming func merging(assignmentsFrom assignments: Context) -> Context {
		with(self) { result in
			result.values.merge(assignments.values, uniquingKeysWith: { $1 })
		}
	}
	
}

extension Shadow {
	
	/// The context of the shadow, i.e., including contextual values from parent shadows.
	var context: Context {
		get async throws {
			try await cached(in: \.context) {	// TODO: Fine-grained dependency per contextual property?
				let parentContext = try await directParent?.context ?? .init()
				return parentContext.merging(assignmentsFrom: await self.assignedContext)
			}
		}
	}
	
	/// Assigns or reassigns the contextual value for given key.
	func context<Value>(_ key: Context.Key<Value>, _ value: Value) async throws {
		var context = Context()
		context[key] = value
		try await set(\.assignedContext, context)
	}
	
}

fileprivate extension ShadowSnapshot {
	
	/// The context of the shadow, i.e., including contextual values from parent shadows, or `nil` if it has not been computed yet.
	var context: Context? {
		get { self[\.context] }
		set { self[\.context] = newValue }
	}
	
	/// The context assigned on the shadow, or an empty context if the shadow does not represent a context modifier.
	var assignedContext: Context {
		get { self[\.assignedContext] ?? .init() }
		set { self[\.assignedContext] = newValue }
	}
	
}
