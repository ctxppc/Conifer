// Conifer © 2019–2025 Constantino Tsarouhas

/// A value representing a rendered component and properties related to it.
///
/// ## Components Are Rendered in a Shadow Graph
/// Every non-foundational component of type `T` is represented by some `Shadow<T>` value in a `ShadowGraph` in a process called **rendering**. Foundational components (`Either`, `Empty`, `ForEach`, `Group`, `Modified`, and `Never`) are part of a shadow graph but are not directly represented by shadows (except in a few internal cases). They are instead represented by their non-foundational children.
///
/// A component can be rendered using the global `makeShadow(over:)` function.
///
/// 	let documentComponent = HTMLDocument { … }
/// 	let documentShadow = makeShadow(over: documentComponent)
///
/// A shadow's descendants can be accessed via its `children` property. The shadow graph lazily renders components as they are accessed. A shadow's parent can be accessed via its `parent` property. A rendered component's ancestors are always rendered.
///
/// ## Shadow Properties
/// Besides storing a rendered representation of a component, a shadow can have properties related to that component. These **shadow properties** can be either stored or computed. A **shadow value** is a value of some shadow property of some shadow.
///
/// A **stored shadow property** is a shadow property whose storage is managed by the shadow graph and whose value is set during rendering (such as a modifier that sets its value when its `update(_:)` method is invoked) or by an external source (such as a database after it detects changes to a query result set).
///
/// To declare a stored shadow property, declare a property in an extension of `ShadowSnapshot` (not `Shadow`). Stored shadow properties can be accessed and updated directly on a shadow, without having to acquire a snapshot first, even though the property is defined on `ShadowSnapshot` and not `Shadow`. See `ShadowSnapshot` for more information on defining stored shadow properties.
///
///		extension ShadowSnapshot {	// not Shadow
///			var prefersPrettyPrint: Bool { … }
/// 	}
///
/// 	let myShadow: any Shadow = …
/// 	let printPrettily = await myShadow.prefersPrettyPrint
/// 	await myShadow.set(\.prefersPrettyPrint, false)
///
/// A **computed shadow property** is a shadow property that depends on other shadow values, whether from the same or other shadows in the graph. To declare a computed shadow property, declare a property on this protocol or a specialisation (not `ShadowSnapshot`). A computed shadow property has an `async` getter if it accesses the shadow graph.
///
/// 	extension Shadow {	// not ShadowSnapshot
///			var isRootElement: Bool {
///				get async { return /* traverse ancestors to determine value */ }
///			}
/// 	}
///
/// 	let myShadow: any Shadow = …
/// 	let isRootElement = await myShadow.isRootElement
///
/// For best performance, a computed shadow property should cache its result in a stored shadow property. The computed shadow property should use `cached(in:compute:)` to participate in Conifer's dependency tracking mechanism. Each shadow value that is read during the call to `cached(in:compute:)` is recorded as a dependency of the computed shadow property. The computed shadow property is invalidated whenever any dependency changes, except if this occurs within the same `cached(in:compute:)` call. `cached(in:compute:)` stores the computed value in the backing stored property; Conifer resets it to `nil` when it is invalidated.
///
/// 	extension Shadow {
///			var isRootElement: Bool {
///				get async throws {
///					try await cached(in: \.isRootElement) { // refers to the stored property defined in ShadowSnapshot below
///						return /* traverse ancestors to determine value */
///					}
///				}
///			}
///		}
///
///		extension ShadowSnapshot {
///			fileprivate var isRootElement: Bool? { … }	// of optional type
///		}
///
/// ## Conifer Provides a Conforming Type
/// Conifer provides `ShadowType`, a concrete type that conforms to `Shadow`. There is usually no need for a custom type conforming to `Shadow`, nor will Conifer instantiate or store such types.
///
/// To add methods, subscripts, and computed properties, extend `Shadow`. To add stored shadow properties, extend `ShadowSnapshot` (cf above).
///
/// ## Specialising the Shadow Protocol
/// When specialising the `Component` protocol, also specialise the `Shadow` protocol and add conformance to the concrete `ShadowType` type to enable dynamic casting. For example, given following `Component` specialisation
///
/// 	protocol HTMLElement : Component where Body : HTMLElement { … }
///
/// define this `Shadow` specialisation and `ShadowType` conformance
///
/// 	protocol HTMLElementShadow : Shadow where Subject : HTMLElement {}
/// 	extension ShadowType : HTMLElementShadow where Subject : HTMLElement {}
///
/// Add any extensions conditionally to the *general* `Shadow` protocol instead of adding them unconditionally to the `Shadow` *specialisation*. For example,
///
/// 	extension Shadow where Subject : HTMLElement {
///			var htmlRepresentation: String { … }
///			var prefersPrettyPrint: Bool { … }
///			func preferPrettyPrint(_ newValue: Bool) async { … }
/// 	}
///
/// The reason for doing so is that Conifer API never constrains, and indeed cannot contrain, shadows to domain-specific component types. The specialisation allows you to use dynamic casting over unconstrained `Shadow` values, like when defining a modifier type. (Does this argument still hold?)
///
/// 	struct PrettyPrintModifier : Modifier {
///			func update(_ shadow: some Shadow) async {
///				if let s = shadow as? HTMLElementShadow {
///					s.preferPrettyPrint(true)
///				} else {
///					// do something else
///				}
///			}
/// 	}
///
/// ## Do Not Store Shadows in a Shadow Graph
/// A `Shadow` keeps a strong reference to the underlying shadow graph, i.e., a shadow graph exists as long as any `Shadow` references it. While this is desirable behaviour in most case, it causes a strong reference cycle if a shadow is stored in a shadow graph, which may cause a resource leak, as in the example below.
///
///		extension ShadowSnapshot {
///			var selfReference: (any Shadow)? {
///				get { self[\.selfReference] }
///				get { self[\.selfReference] = newValue }
///			}
///		}
///		let component: some Component = …
///		let shadow = try await makeShadow(over: component)
///		let graph = shadow.graph
///		await shadow.set(\.selfReference, shadow)	// this creates a strong reference cycle!
///		let shadow2 = await shadow.selfReference
///		// `graph`, `shadow`, and `shadow2` are not used anymore, yet `graph` is not deallocated
///
/// To avoid this, store the shadow location and recreate the shadow whenever needed instead.
///
///		extension ShadowSnapshot {
///			var selfReference: ShadowGraph.Location? {	// store a location instead of a shadow
///				get { self[\.selfReference] }
///				get { self[\.selfReference] = newValue }
///			}
///		}
///		let component: some Component = …
///		let shadow = try await makeShadow(over: component)
///		let graph = shadow.graph
///		await shadow.set(\.selfReference, shadow.location)	// store a location instead of a shadow
///		let shadow2 = ShadowType(graph: graph, location: shadow.selfReference)	// recreate shadow
///		// `graph`, `shadow`, and `shadow2` are not used anymore, thus `graph` is deallocated
@dynamicMemberLookup	// properties on snapshot
public protocol Shadow<Subject> : Sendable {
	
	/// Creates a shadow in a given graph over a component at given location in the graph.
	///
	/// - Requires: The component at `location` in `graph` exists and is a `Subject`. Or more formally, `graph.renderIfNeededComponent(at: location)` returns a component of type `Subject`.
	///
	/// - Parameters:
	///   - graph: The graph.
	///   - location: The subject's location in the graph.
	init(graph: ShadowGraph, location: ShadowGraph.Location)
	
	/// The graph backing `self`.
	var graph: ShadowGraph { get }
	
	/// The location of the subject relative to the root component in `graph`.
	///
	/// - Invariant: `location` refers to an already rendered component in `graph`.
	var location: ShadowGraph.Location { get }
	
	/// A component represented by an instance of`Self`.
	associatedtype Subject : Component
	
}

extension Shadow {
	
	/// Performs a given function within the shadow graph's isolation domain and returns its result.
	func withGraph<E, R : Sendable>(perform: (isolated ShadowGraph) async throws(E) -> R) async throws(E) -> R {
		try await perform(graph)
	}
	
}

extension Component {
	
	/// Creates a shadow over `self` with a given graph and a given location on the graph.
	///
	/// - Parameters:
	///   - graph: The graph.
	///   - location: The location of `self` in `graph`.
	///
	/// - Requires: `location` refers to a rendered component in `graph` that is equal to `self`.
	func makeShadow(graph: ShadowGraph, location: ShadowGraph.Location) -> some Shadow<Self> {
		ShadowType(graph: graph, location: location)
	}
	
	/// Creates an untyped shadow over `self` with a given graph and a given location on the graph.
	///
	/// - Parameters:
	///   - graph: The graph.
	///   - location: The location of `self` in `graph`.
	///
	/// - Requires: `location` refers to a rendered component in `graph` that is equal to `self`.
	func makeUntypedShadow(graph: ShadowGraph, location: ShadowGraph.Location) -> some Shadow {
		ShadowType<Self>(graph: graph, location: location)
	}
	
}

/// Creates a shadow over `subject`.
///
/// This function creates a new shadow graph rooted in `subject`.
///
/// - Requires: `subject` is not a foundational component.
///
/// - Parameter subject: The component over which to create a shadow.
///
/// - Returns: A shadow over `subject` in a new shadow graph.
public func makeShadow<C : Component>(over subject: C) async throws -> some Shadow<C> {
	precondition(!(subject is any FoundationalComponent), "Cannot make a shadow over foundational component \(subject)")
	return ShadowType(graph: try await .init(root: subject), location: .anchor)
}
