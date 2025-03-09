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
/// Besides storing a rendered representation of a component, a shadow can have properties related to that component. Shadow properties can be either stored or computed.
///
/// A **stored shadow property** is a shadow property whose storage is managed by the shadow graph. To declare a stored shadow property, declare a property in an extension of `ShadowSnapshot` (not `Shadow`). Stored shadow properties can be accessed and updated directly on a shadow, without having to acquire a snapshot first, even though the property is defined on `ShadowSnapshot` and not `Shadow`.
///
///		extension ShadowSnapshot {	// not Shadow
///			var prefersPrettyPrint: Bool { … }
/// 	}
///
/// 	let myShadow: any Shadow = …
/// 	let printPrettily = await myShadow.prefersPrettyPrint
/// 	await myShadow.set(\.prefersPrettyPrint, false)
///
/// A **computed shadow property** is a shadow property that depends on other shadow properties, whether the same or other shadows in the graph, or an external source of truth (such as a database). To declare a computed shadow property, declare a property on this protocol or a specialisation (not `ShadowSnapshot`). A computed shadow property has an `async` getter if it accesses the shadow graph.
///
/// 	extension Shadow {	// not ShadowSnapshot
///			var isRootElement: Bool {
///				get async { /* traverse ancestors to determine value */ }
///			}
/// 	}
///
/// 	let myShadow: any Shadow = …
/// 	let isRootElement = await myShadow.isRootElement
///
/// For best performance, a computed shadow property should cache its result in a stored shadow property.
///
/// 	extension Shadow {
///			var isRootElement: Bool {
///				get async {
///					if let isRootElement = await isRootElementIfKnown {
///						return isRootElement
///					} else {
///						let isRootElement = /* traverse ancestors to determine value */
///						set(\.isRootElementIfKnown, isRootElement)
///						return isRootElement
///					}
///				}
///			}
///		}
///
///		extension ShadowSnapshot {
///			fileprivate var isRootElementIfKnown: Bool? { … }
///		}
///
/// ## Shadow Property Accesses Are Tracked During Rendering
/// A shadow graph tracks accesses to properties while a component is being rendered.
///
/// A modifier or dynamic property that *reads* a shadow property creates a **dependency** between the shadow property and the modifier resp. property's dependent component.
///
/// A modifier or dynamic property that *writes* a shadow property using `update(_:ofType:)` or `update(_:with:)` invalidates the components that depend on it.
///
/// Carefully document the shadow properties a component defines (writes) or uses (reads) to avoid cyclic dependencies.
///
/// ## Conifer Provides a Conforming Type
/// Conifer provides `ShadowType`, a concrete type that conforms to `Shadow`. There is usually no need for a custom type conforming to `Shadow`, nor will Conifer instantiate or store such types.
///
/// To add methods, subscripts, and computed properties, extend `Shadow`. For storage, define shadow properties (cf. above).
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
/// Add any extensions conditionally to the general `Shadow` protocol instead of adding them unconditionally to the `Shadow` specialisation. For example,
///
/// 	extension Shadow where Subject : HTMLElement {
///			var htmlRepresentation: String { … }
///			var prefersPrettyPrint: Bool { … }
///			func preferPrettyPrint(_ newValue: Bool) async { … }
/// 	}
///
/// Conifer API never constrains, and indeed cannot contrain, shadows to domain-specific component types. The specialisation allows you to use dynamic casting over unconstrained `Shadow` values, like when defining a modifier type.
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
	
	/// The shadow of the nearest non-foundational ancestor component, or `nil` if `self` is a root component.
	///
	/// - Invariant: `parent` is not a foundational component.
	public var parent: (any Shadow)? {
		get async {
			// Sequence.map and .compactMap do not support await (yet) so we use a conventional loop.
			for location in sequence(first: location, next: \.parent) {
				let subject = await graph.prerenderedComponent(at: location)
				if !(subject is any FoundationalComponent) {
					return subject.makeUntypedShadow(graph: graph, location: location)
				}
			}
			return nil
		}
	}
	
	/// Returns the children of `self`, i.e., shadows over the non-foundational components that are direct descendants of `subject`.
	///
	/// - Requires: Each child is typed `type`.
	/// - Requires: `Child` conforms to `Shadow` or is an existential `Shadow` type. (This constraint cannot be formalised as of writing; existential types cannot conform to protocols yet.)
	/// - Invariant: No component in `children` is a foundational component.
	public func children<Child>(ofType type: Child.Type) -> some AsyncSequence<Child, any Error> {
		ShadowChildren(parent: self)
	}
	
	/// Accesses a shadow property at a given key path on `self`.
	///
	/// If a component is being rendered, this method records a dependency of that component on the shadow property on `self`. That component is invalidated whenever the shadow property changes.
	public subscript <Value : Sendable>(dynamicMember keyPath: WritableKeyPath<ShadowSnapshot, Value> & Sendable) -> Value {
		get async {
			await { (graph: isolated ShadowGraph) in
				graph.recordRead(from: location, property: keyPath)
				return graph[location]![keyPath: keyPath]
			}(graph)
		}
	}
	
	/// Assigns or reassigns a value to a shadow property at a given key path on `self`.
	///
	/// This method invalidates all components that depend on the shadow property.
	public func set<Value : Sendable>(_ keyPath: WritableKeyPath<ShadowSnapshot, Value> & Sendable, _ newValue: Value) async {
		await { (graph: isolated ShadowGraph) in
			graph.recordWrite(to: location, property: keyPath)
			graph[location]![keyPath: keyPath] = newValue
		}(graph)
	}
	
	/// Updates a value to a shadow property at a given key path on `self`.
	///
	/// This method invalidates all components that depend on the shadow property.
	public func update<Value : Sendable>(_ keyPath: WritableKeyPath<ShadowSnapshot, Value> & Sendable, with transform: sending (Value) -> Value) async {
		await { (graph: isolated ShadowGraph) in
			graph.recordRead(from: location, property: keyPath)
			graph.recordWrite(to: location, property: keyPath)
			graph[location]![keyPath: keyPath] = transform(graph[location]![keyPath: keyPath])
		}(graph)
	}
	
	/// Returns the associated element of a given type.
	@available(*, deprecated)
	public func element<Element : Sendable>(ofType type: Element.Type) async -> Element? {
		return await graph.element(ofType: type, at: location)
	}
	
	/// Assigns, replaces, or removes the associated element of its type.
	///
	/// `type` can be either a concrete or existential type. Concrete and existential types are never equal; the same type must be provided to `element(ofType:)` to retrieve the same element. It's for example possible to simultaneously assign a `String` element using the `Any` type and another using the `String` type at the same location.
	///
	/// - Parameters:
	///   - element: The new element, or `nil` to remove it.
	///   - type: The element's type. The default value is the element's concrete type, which is sufficient unless an existential type is desired.
	@available(*, deprecated)
	public func update<Element : Sendable>(_ element: Element?, ofType type: Element.Type = Element.self) async {
		await graph.update(element, ofType: type, at: location)
	}
	
	/// Assigns, replaces, or removes the associated element of its type using a given update function.
	///
	/// `type` can be either a concrete or existential type. Concrete and existential types are never equal; the same type must be provided to `element(ofType:)` to retrieve the same element. It's for example possible to simultaneously assign a `String` element using the `Any` type and another using the `String` type at the same location.
	///
	/// - Parameters:
	///   - type: The element's type.
	///   - update: A function that accepts the current element of type `type` (or `nil` if `self` has no such element) and produces the new element (or `nil` if there should be no such element).
	@available(*, deprecated)
	public func update<Element : Sendable, Failure>(
		_ type:			Element.Type,
		with update:	sending (Element?) async throws(Failure) -> Element?
	) async throws(Failure) {
		try await graph.update(type, with: update, at: location)
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
