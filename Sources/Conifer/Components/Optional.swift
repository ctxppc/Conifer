// Conifer © 2019–2023 Constantino Tsarouhas

extension Optional : Component where Wrapped : Component {
	
	public var body: Either<Wrapped, Empty/*<Artefact>*/> {
		self ?? Empty()
	}
	
	/* public typealias Artefact = Wrapped.Artefact */
	
}
