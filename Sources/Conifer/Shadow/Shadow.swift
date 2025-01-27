// Conifer © 2019–2025 Constantino Tsarouhas

/// A value representing a rendered component and its associated elements.
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
/// ## Shadows Can Have Associated Elements
/// Besides storing a rendered representation of a component, a shadow can have associated elements. Each element is identified by the type of element.
///
/// The `update(_:ofType:)` method on a shadow associates an element of a given type with the shadow. The `element(ofType:)` method retrieves it.
///
/// 	documentShadow.update("test", ofType: String.self)
///		documentShadow.element(ofType: String.self)		// "test"
///
/// The element type in `update(_:ofType:)` defaults to the value's concrete type. The first method call can therefore also be written as:
///
///		documentShadow.update("test")
///
/// In some cases, it's useful to use a supertype, such as an existential type, as an identifier.
///
/// 	documentShadow.update("test", ofType: (any Comparable).self)
/// 	documentShadow.element(ofType: (any Comparable).self)		// "test"
/// 	documentShadow.update(60, ofType: (any Comparable).self)
/// 	documentShadow.element(ofType: (any Comparable).self)		// 60
///
/// Shadow graphs are actors. Elements must therefore be `Sendable` since they often cross a shadow graph's isolation boundary.
///
/// Conifer uses the `any Component` existential type to represent rendered components. Do not use this type when invoking `update(_:ofType:)` as this breaks internal invariants. Avoid accessing rendered components via `element(ofType:)` as this is not part of the API's contract and may change at any time.
///
/// ## Associated Elements Create Dependencies During Rendering
/// A shadow graph tracks accesses to elements while a component is being rendered.
///
/// A modifier or dynamic property that *reads* an element using `element(ofType:)` or `update(_:with:)` creates a **dependency** between the element and the modifier resp. property's dependent component.
///
/// A modifier or dynamic property that *writes* an element using `update(_:ofType:)` or `update(_:with:)` invalidates the components that depend on it.
///
/// Carefully document the elements a component defines (writes) or uses (reads) to avoid cyclic dependencies.
///
/// ## Conifer Provides a Conforming Type
/// Conifer provides `ShadowType`, a concrete type that conforms to `Shadow`. There is usually no need for a custom type conforming to `Shadow`, nor will Conifer instantiate or store such types.
///
/// To add methods, subscripts, and computed properties, extend `Shadow`. For storage, use associated elements.
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
/// Conifer API never constrains, and indeed cannot contrain, shadows to domain-specific component types. The specialisation allows you to use dynamic casting over unconstrained `Shadow` values, like when defining a modifier type,
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
///		struct MyElement : Sendable {
///			var selfReference: any Shadow
///		}
///		let component: some Component = …
///		let shadow = try await makeShadow(over: component)
///		let graph = shadow.graph
///		await shadow.update(MyElement(selfReference: shadow)
///		let shadow2 = shadow.element(ofType: MyElement.self)!.selfReference
///		// `graph`, `shadow`, and `shadow2` are not used anymore, yet `graph` is not deallocated
///
/// To avoid this, store the shadow location and recreate the shadow whenever needed instead.
///
///		struct MyElement : Sendable {
///			var selfReference: ShadowLocation	// store a location instead of a shadow
///		}
///		let component: some Component = …
///		let shadow = try await makeShadow(over: component)
///		let graph = shadow.graph
///		await shadow.update(MyElement(selfReference: shadow.location)	// store a location instead of a shadow
///		let shadow2 = ShadowType(graph: graph, location: shadow.element(ofType: MyElement.self)!.selfReference)	// recreate shadow
///		// `graph`, `shadow`, and `shadow2` are not used anymore, thus `graph` is deallocated
@dynamicMemberLookup
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
	
	/// Returns the associated element of a given type.
	///
	/// If a component is being rendered, this method records a dependency between the component being rendered, i.e., the *dependent component*, and the element being accessed. The graph invalidates the dependent component when the element of type `type` is updated on `self`.
	public func element<Element : Sendable>(ofType type: Element.Type) async -> Element? {
		await graph.recordRead(at: location, elementType: type)
		return await graph.element(ofType: type, at: location)
	}
	
	/// Assigns, replaces, or removes the associated element of its type.
	///
	/// `type` can be either a concrete or existential type. Concrete and existential types are never equal; the same type must be provided to `element(ofType:)` to retrieve the same element. It's for example possible to simultaneously assign a `String` element using the `Any` type and another using the `String` type at the same location.
	///
	/// This method invalidates any components that depend on the element being updated.
	///
	/// - Parameters:
	///   - element: The new element, or `nil` to remove it.
	///   - type: The element's type. The default value is the element's concrete type, which is sufficient unless an existential type is desired.
	public func update<Element : Sendable>(_ element: Element?, ofType type: Element.Type = Element.self) async {
		await graph.recordWrite(at: location, elementType: type)
		await graph.update(element, ofType: type, at: location)
	}
	
	/// Assigns, replaces, or removes the associated element of its type using a given update function.
	///
	/// `type` can be either a concrete or existential type. Concrete and existential types are never equal; the same type must be provided to `element(ofType:)` to retrieve the same element. It's for example possible to simultaneously assign a `String` element using the `Any` type and another using the `String` type at the same location.
	///
	/// If a component is being rendered, this method records a dependency between the component being rendered, i.e., the *dependent component*, and the element being accessed. The graph invalidates the dependent component when the element of type `type` is updated on `self`. Additionally, this method invalidates any components that depend on the element being updated.
	///
	/// - Parameters:
	///   - type: The element's type.
	///   - update: A function that accepts the current element of type `type` (or `nil` if `self` has no such element) and produces the new element (or `nil` if there should be no such element).
	public func update<Element : Sendable, Failure>(
		_ type:			Element.Type,
		with update:	sending (Element?) async throws(Failure) -> Element?
	) async throws(Failure) {
		await graph.recordRead(at: location, elementType: type)
		await graph.recordWrite(at: location, elementType: type)	// TODO: Does this work?
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
