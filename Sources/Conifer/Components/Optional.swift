// Conifer © 2019–2024 Constantino Tsarouhas

extension Optional : Component where Wrapped : Component {
	public var body: Either<Wrapped, Group<>> {
		self ?? Group {}
	}
}
