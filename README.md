# The *Conifer* framework

**Conifer** is a framework for designing and manipulating declarative, contextual, complex tree structures in Swift.

Conifer's main use is as part of other frameworks or libraries, such as web application frameworks or declarative data structure models.

## Components
A **component** is a node in a tree. Components have value semantics, making it easier to reason about them.

Conifer defines a `Component` protocol to which all component types conform to. The protocol defines only one requirement, the body, which is itself a component.

	public protocol Component {
		associatedtype Body : Component
		var body: Body { get }
	}

Concrete component types are defined by Conifer clients, with Conifer only providing a few fundamental types. For instance, a web framework may define `Heading`, `Paragraph`, and `Text` component types.

	public struct Heading<Contents : Component> : Component { /* … */ }
	public struct Paragraph<Contents : Component> : Component { /* … */ }
	public struct Text : Component { /* … */ }

A client of the web framework may use these component types to write a web page:

	struct Introduction : Component {
		var body: some Component {
			Heading {
				Text(value: "Introduction")
			}
			Paragraph {
				Text(value: "This text aims to introduce the reader to the science of dendrology.")
			}
		}
	}

Conifer libraries should specialise this protocol as appropriate for their domain model. For instance, a web application framework might declare an `Element` protocol specialising `Component` as follows:

	public protocol Element : Component where Body : Element {}

The `Body : Element` constraint ensures that the complete tree recursively conforms to the `Element` protocol.

## Lazy rendering & shadow tree
Dealing with deep structured values incurs a significant amount of overhead. Additionally, parts of a component tree may not be needed in some cases, e.g., parts of a user interface that is hidden. For these reasons, a Conifer client doesn't interact directly with a component tree via the `body` property. Conifer instead provides access to a **shadow**, which is a lazily evaluated tree. A shadow can be queried using a selector whose syntax looks suspiciously a lot like those of CSS selectors.

In the example below, only the `Heading` component and its `Text` subcomponent are rendered. Conifer skips rendering the `Paragraph` component.

	let shadow = Shadow(of: Introduction())
	let allHeadingTexts = shadow[Heading.self > Text.self]
	print(allHeadingTexts[0].value)	// "Introduction"

## Component transformation
A component can be transformed to a different representation by a `RewriteRule` that takes a component in one representation and returns a component in a different representation. A rewrite rule specifies a selector which, given a component, selects a number of components or subcomponents. Each selected component is fed to `rewrite(_:)` which generates a new component.

In the example below, the web framework defines a different set of component types that can be readily serialised into text and a few rewrite rules that emit those types of components.

	struct HTMLElement : Component { /* … */ }
	struct HTMLText : Component { /* … */ } 
	
	struct ElementRewriteRule : RewriteRule {
		var pattern: some Selector { .any }
		func rewrite(_ element: Shadow<some Component>) throws async -> some Component {
			try await (ParagraphRewriteRule() | SimpleParagraphRewriteRule() | HeadingRewriteRule() | SimpleHeadingRewriteRule())
				.rewrite(element)
		}
	}
	
	struct ParagraphRewriteRule : RewriteRule {
		var pattern: some Selector { .typed(Paragraph.self) }
		func rewrite(_ paragraph: Shadow<Paragraph<some Component>>) throws async -> some Component {
			HTMLElement(tagName: "p") {
				try await ElementRewriteRule().rewrite(paragraph.body)
			}
		}
	}
	
	struct SimpleParagraphRewriteRule : RewriteRule {
		var pattern: some Selector { Paragraph.self > Text.self }
		func rewrite(_ text: Shadow<Text>) -> some Component {
			HTMLElement(tagName: "p") {
				HTMLText(value: text.value)
			}
		}
	}
	
	// analogously for HeadingRewriteRule and SimpleHeadingRewriteRule
