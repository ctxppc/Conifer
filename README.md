# The *Conifer* framework

**Conifer** is a framework for designing declarative, contextual, complex tree structures in Swift.

Conifer's main use is as part of other frameworks or libraries, such as web application frameworks or declarative data structure models.

## Components
**Components** are the user-visible building blocks of a Conifer library. A component is a *value* (not object) that determines a part of the underlying tree (discussed below). Whereas the tree has reference semantics, components have value semantics, making it easier for users to reason about them.

Conifer defines a `Component` protocol to which all component types conform to. The protocol defines only one requirement, the body, which is itself a component.

	public protocol Component {
		associatedtype Body : Component
		var body: Body { get }
	}

Components usually represent one node in the underlying tree but this is not necessarily the case. An archetypal example is `Group` which can be used to declare multiple (sibling) components at once, each representing a subnode (or leaf). For example,

	struct Introduction : Component {
		var body: some Component {
			Group {
				Heading("Introduction")
				Paragraph("This text aims to introduce the reader to the science of dendrology.")
			}
		}
	}

Conifer libraries should specialise this protocol as appropriate for their domain model. For instance, a web application framework might declare an `Element` protocol specialising `Component` as follows:

	public protocol Element : Component where Body : Element {}

The `Body : Element` constraint ensures that the complete tree recursively conforms to the `Element` protocol.

## Nodes
Components are translated to domain-specific **nodes** of an underlying tree. The tree isn't usually exposed to a user of the Conifer library, who instead exclusively works with components. Nodes are objects conforming to the `Node` protocol.
