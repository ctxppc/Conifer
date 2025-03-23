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
public struct Context : @unchecked Sendable {	// Only immutable key paths without functions
	
	/// Creates an empty context.
	init() {}
	
	/// The contextual values.
	private var values = [AnyKey : any Sendable]()
	private typealias AnyKey = PartialKeyPath<Self>
	public typealias Key<Value> = WritableKeyPath<Self, Value> where Value : Sendable
	
	/// Accesses the contextual value at a given key.
	public subscript <Value>(key: Key<Value>) -> Value {
		get { (values[key as AnyKey] !! "\(key) not available in context (\(self))") as! Value }
		set { values[key as AnyKey] = newValue }
	}
	
}

extension Shadow {
	
	/// The context of the shadow, i.e., including contextual values from parent shadows.
	var context: Context {
		get async {
			if let context = await self.computedContext {
				return context
			} else {
				// FIXME: Collapse multiple suspension points to avoid read-write races.
				let context = await parent?.context ?? .init()	// TODO: Quid dependency tracking?
				try! await set(\.computedContext, context)	// FIXME: Handle error
				return context
			}
		}
	}
	
	/// Assigns or reassigns the contextual value for given key.
	func set<Value>(_ key: Context.Key<Value>, _ value: Value) async {
		var context = await self.context
		context[keyPath: key] = value
		try! await self.set(\.computedContext, context)	// FIXME: Handle error
	}
	
}

fileprivate extension ShadowSnapshot {
	
	/// The context of the shadow, i.e., including contextual values from parent shadows, or `nil` if it has not been computed yet.
	var computedContext: Context? {
		get { self[\.computedContext] }
		set { self[\.computedContext] = newValue }
	}
	
}
