# The *Conifer* framework
**Conifer** is a framework for building and manipulating declarative, contextual, complex tree structures in Swift. It provides a domain-specific language for expressing hierarchical data (e.g., user interface elements) as well as tools to conveniently transform this data (e.g., to HTML elements).

	struct Introduction : Component {
		var body: some Component {
			Heading {
				Text(value: "Introduction")
			}
			Paragraph {
				Text(value: "This page aims to introduce the reader to the science of dendrology.")
			}
		}
	}

Conifer's main use is as part of other frameworks or libraries, such as web application frameworks or declarative data structure models.

## Documentation
1. [Components](Documentation/1 Components.md)
2. [Shadows](Documentation/2 Shadows.md)
3. [Dependencies](Documentation/3 Dependencies.md)
