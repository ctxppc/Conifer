# Selectors
Conifer lazily computes components, i.e., children of components are not realised until they are needed. To efficiently traverse such components, Conifer allows clients to interact with components using **selectors**, which are predicates over components and paths. Selectors in Conifer are similar to Swift keypaths, XPath expressions, or to CSS selectors. Clients can define their own types of selectors besides using those provided by Conifer.

All selectors conform to the `Selector` protocol and can be applied directly on a shadow using its subscript operator. In the following example, a simple selector is applied on a single component.

	struct Person : Component {
		var name: String
		var body: some Component {}
	}
	
	struct Department : Component {
		var name: String
		var age: Int
		var body: some Component {
			Person(name: "John", age: 28)
			Person(name: "Ellie", age: 33)
		}
	}
	
	let dept = Shadow(of: Department())
	let selector = Selector.children.typed(Person.self).where(\.name == "John")
	let johns = dept[selector]
	print(johns[0].age)	// 28

The **subject** of a selector is the component on which the selector is applied. The subject in the example above is `dept`. A **result** of a selector is a component produced by the selector, such as `johns[0]` above.

## Child selector
The **child selector** `selector.children` selects all direct children of all components selected by `selector`.

## Type selector
The **type selector** `selector.typed(type)` selects the components selected by `selector` that are of type `type`.

A type selector produces a typed selector, i.e., a selector whose components have a static type. Some kinds of selectors (like predicate selectors) are only valid on typed selectors.

## Predicate selector
The **predicate selector** `selector.where(predicate)` on a typed selector `selector` selects the components selected by `selector` where `predicate` holds.

## Index selector
The **index selector** `selector[index]` selects the `index`th component in the list of components selected by `selector`, where `index` of the first component is 0.

## Parent selector
The **parent selector** `selector.parents` selects the parent of each component selected by `selector`.
