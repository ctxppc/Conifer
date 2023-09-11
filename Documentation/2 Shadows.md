# Shadows
Conifer lazily computes and caches components in a tree. This allows developers to easely write lazy algorithms on very large (possibly infinite) trees.

Since Conifer is responsible for managing the computation of components, accesses to subcomponents are regulated through **shadows**, which represents an instantiated component in a component tree. A shadow allows for full traversal, including to the parent of the shadowing component.

Shadows are values of Conifer's `Shadow` type, which looks like this:

	struct Shadow<Subject : Component> {
		
		var parent: Shadow<any Component>
		var children: some AsyncCollection<Shadow<any Component>>
		
		var body: Shadow<Subject.Body>
		subscript <Value>(dynamicMember keyPath: KeyPath<Subject, Value>) -> Value
		
	}

Thanks to `Shadow`'s `subscript(dynamicMember:)`, the shadowing component's properties can be accessed directly on the shadow.

	struct Button : Component {
		var title: String
		var body: some Component { … }
	}
	
	let buttonShadow: Shadow<Button> = …
	let title = buttonShadow.title

Every shadow is part of a shadow tree. A shadow retrieved via the `parent`, `children`, or `body` properties of a shadow are part of the same shadow tree as the latter shadow. Shadow trees are actors: all accesses are serialised through them.

You can create a new (independently computed and cached) shadow tree for a given root component using the `Shadow(of:)` initialiser.

	let buttonShadow = Shadow(of: Button(title: "Click here!"))
