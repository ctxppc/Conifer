// Conifer © 2019–2024 Constantino Tsarouhas

/// A value representing a rendered component, its content, and its associated elements.
///
/// # Components Are Rendered in a Shadow Graph
/// Every non-foundational component of type `T` is represented by some `Shadow<T>` value in a `ShadowGraph` in a process called **rendering**. Foundational components (`Either`, `Empty`, `ForEach`, `Group`, `Modified`, and `Never`) do not have a shadow in a shadow graph; their constituent components, if there are any, are rendered in their place.
///
/// A component can be rendered using the global `makeShadow(over:)` function.
///
/// 	let documentComponent = HTMLDocument { … }
/// 	let documentShadow = makeShadow(over: documentComponent)
///
/// A shadow's descendants can be accessed via its `children` property. The shadow graph lazily renders components as they are accessed. A shadow's parent can be accessed via its `parent` property. A rendered component's ancestors are always rendered.
///
/// # Shadows Can Have Associated Elements
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
/// # Conifer Provides a Conforming Type
/// Conifer provides `ShadowType`, a concrete type that conforms to `Shadow`. There is usually no need for a custom type conforming to `Shadow`, nor will Conifer instantiate or store such types.
///
/// To add methods, subscripts, and computed properties, extend `Shadow`. For storage, use associated elements.
///
/// # Specialising the Shadow Protocol
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
@dynamicMemberLookup
public protocol Shadow<Subject> : Sendable {
	
	/// Creates a shadow in a given graph over a component at given location in the graph.
	///
	/// - Parameters:
	///   - graph: The graph.
	///   - location: The subject's location in the graph.
	init(graph: ShadowGraph, location: ShadowLocation)
	
	/// The graph backing `self`.
	var graph: ShadowGraph { get }
	
	/// The location of the subject relative to the root component in `graph`.
	///
	/// - Invariant: `location` refers to an already rendered component in `graph`.
	var location: ShadowLocation { get }
	
	/// A component represented by an instance of`Self`.
	associatedtype Subject : Component
	
}

extension Shadow {
	
	/// The component represented by `self`.
	public var subject: Subject {
		get async throws {
			try await graph[location] as! Subject
		}
	}
	
	/// The shadow of the nearest non-foundational ancestor component, or `nil` if `self` is a root component.
	///
	/// - Invariant: `parent` is not a foundational component.
	public var parent: (any Shadow)? {
		get async {
			// Sequence.map and .compactMap do not support await (yet) so we use a conventional loop.
			for location in sequence(first: location, next: \.parent) {
				let subject = await graph[prerendered: location]
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
	/// - Invariant: No component in `children` is a foundational component.
	public func children<T>(ofType type: T.Type) -> ShadowChildren<Self, T> {
		.init(parentShadow: self)
	}
	
	/// Returns the associated element of a given type.
	public func element<Element : Sendable>(ofType type: Element.Type) async -> Element? {
		await graph.element(ofType: type, at: location)
	}
	
	/// Assigns or replaces the associated element of its type.
	///
	/// `type` can be either a concrete or existential type. Concrete and existential types are never equal; the same type must be provided to `element(ofType:)` to retrieve the same element. It's for example possible to simultaneously assign a `String` element using the `Any` type and another using the `String` type at the same location.
	///
	/// - Parameters:
	///   - element: The new element.
	///   - type: The element's type. The default value is the element's concrete type, which is sufficient unless an existential type is desired.
	public func update<Element : Sendable>(_ element: Element, ofType type: Element.Type = Element.self) async {
		await graph.update(element, ofType: type, at: location)
	}
	
	/// Accesses the subject.
	public subscript <Value>(dynamicMember keyPath: KeyPath<Subject, Value>) -> Value {
		get async throws {
			try await subject[keyPath: keyPath]
		}
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
	precondition(!(subject is any FoundationalComponent), "\(subject) is a foundational component")
	return ShadowType(graph: try await .init(root: subject), location: .anchor)
}
