// Conifer © 2019–2025 Constantino Tsarouhas

extension Optional : Component where Wrapped : Component {
	public var body: Either<Wrapped, Empty> {
		self ?? Empty()
	}
}
