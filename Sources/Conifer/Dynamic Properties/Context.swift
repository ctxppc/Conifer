// Conifer © 2019–2024 Constantino Tsarouhas

import DepthKit

/// A container of values propagated through a component hierarchy.
///
/// The context of a component is set up by its ancestor components. It is a mechanism by which information can flow from parent component to child components without having to define a property for every possible piece of information that needs to flow downwards.
///
/// # `@Contextual` Properties
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
public struct Context : @unchecked Sendable {	// KeyPath, an immutable class, is not declared Sendable
	
	/// Creates an empty context.
	init() {}
	
	/// The contextual values.
	private var values = [AnyKey : any Sendable]()
	public typealias AnyKey = PartialKeyPath<Self>
	public typealias Key<Value> = KeyPath<Self, Value>
	
	/// Accesses the contextual value at a given key path.
	public internal(set) subscript <Value>(keyPath: Key<Value>) -> Value {
		get { (values[keyPath as AnyKey] !! "\(keyPath) not available in context (\(self))") as! Value }
		set { values[keyPath as AnyKey] = newValue }
	}
	
}

extension UntypedShadow {
	
	/// The context of `self`.
	var context: Context {
		get async throws {
			if let context = await element(ofType: Context.self) {
				return context
			} else {
				let context = try await parent?.context ?? Context()
				await updateElement(context)
				return context
			}
		}
	}
	
}
