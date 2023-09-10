# Components
Conifer is a tree building & manipulation framework. It provides a DSL, i.e., a domain-specific language, for expressing hierarchical data (e.g., user interface elements) as well as tools to conveniently transform this data (e.g., to HTML elements). Conifer operates on units called **components** which are similar to vertices in a tree. A component can contain zero or more subcomponents.

## Defining a data model
Conifer is a generic framework that can contain operate on all kinds of hierarchical data models. The first step to using Conifer is defining such a model. For example, a data model for web pages consists of HTML nodes containing HTML nodes. This can be expressed in Swift using something as simple as a single `enum` type. The type may define methods that compute a derived value or a different representation, such as a `serialised()` that returns the HTML representation of the node.

	enum HTMLNode {
		
		case comment(String)
		case text(String)
		case element(tag: String, attributes: [String : String] = [:], body: [HTMLNode] = [])
		
		func serialised() -> String { /* return HTML code */ }
		
	}

An example web page expressed using this type could look like this:

	let page: HTMLNode = .element(tag: "html", body: [
		.element(tag: "head", body: [
			.element(tag: "title", body: [.text("Hello, World!")]),
		]),
		.element(tag: "body", body: [
			.element(tag: "h1", body: [.text("Welcome to my web page!")]),
		]),
	])

This approach works well for small types but becomes cumbersome if the type grows with more properties and cases. `enum`s are only advised when the domain of a type is expected to be closed (like `Bool` and `Optional`). A better approach for open-domain types is to define a protocol and `struct` types that conform to it.

	protocol HTMLNode {
		func serialised() -> String
	}
	
	struct CommentNode : HTMLNode {
		var text: String
		func serialised() -> String { … }
	}
	
	struct TextNode : HTMLNode {
		var text: String
		func serialised() -> String { … }
	}
	
	struct ElementNode : HTMLNode {
		var tag: String
		var attributes: [String : String] = [:]
		var body: [any HTMLNode] = []
		func serialised() -> String { … }
	}
	
	let page = ElementNode(tag: "html", body: [
		ElementNode(tag: "head", body: [
			ElementNode(tag: "title", body: [TextNode("Hello, World!")]),
		]),
		ElementNode(tag: "body", body: [
			ElementNode(tag: "h1", body: [TextNode("Welcome to my web page!")]),
		]),
	])

This approach usually works well but may have suboptimal performance when dealing with large values. This is where Conifer comes in.

## Specialising a `Component` protocol
Conifer component types conform to Conifer's `Component` protocol, and usually to a domain-specific specialisation of `Component`.

The `Component` protocol has two (non-defaulted) requirements: an associated type `Body` and a read-only `body` property typed `Body`. It looks something like:

	protocol Component {
		
		associatedtype Body : Component
		
		@ComponentBuilder
		var body: Body { get }
		
	}

The `body` property evaluates to zero or more subcomponents of the component. Conifer provides the `ComponentBuilder` result builder and related types which simplify the expression of component bodies.

Conifer lazily computes the `body` property (and thus the component tree) and caches the result. Accesses to subcomponents (and the larger tree more generally) are regulated through [shadows](2 Shadows.md); you never evaluate the `body` property directly.

`Component` is usually specialised to a domain-specific component protocol which domain-specific component types conform to.

	protocol HTMLNode : Component where Body : HTMLNode {
		static func serialised(_ node: Shadow<Self>) -> String
	}
	
	struct CommentNode : HTMLNode {
		var text: String
		var body: some HTMLNode { /* empty */ }
		static func serialised(_ comment: Shadow<Self>) -> String {
			"<!--\(comment.text.htmlSanitised)-->"
		}
	}
	
	struct TextNode : HTMLNode {
		var text: String
		var body: some HTMLNode { /* empty */ }
		static func serialised(_ textNode: Shadow<Self>) -> String {
			textNode.text.htmlSanitised
		}
	}
	
	struct ElementNode<Body : HTMLNode> : HTMLNode {
		var tag: String
		var attributes: [String : String] = [:]
		var body: Body
		static func serialised(_ element: Shadow<Self>) -> String {
			let atts = element
				.attributes
				.map { "\($0.0)='\($0.1.htmlSanitised)'" }
				.joined(separator: " ")
			let body = element
				.children
				.map { $0.wrappedType.serialised($0) }
				.joined()
			return "<\(element.tag) \(atts)>\(body)</\(tag)>"
		}
	}
	
	let page = ElementNode(tag: "html", body: [
		ElementNode(tag: "head", body: [
			ElementNode(tag: "title", body: [TextNode("Hello, World!")]),
		]),
		ElementNode(tag: "body", body: [
			ElementNode(tag: "h1", body: [TextNode("Welcome to my web page!")]),
		]),
	])