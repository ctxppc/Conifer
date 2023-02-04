// Conifer © 2019–2023 Constantino Tsarouhas

/// A selector of components of a given type.
public struct TypeSelector<ResultComponent : Component> {
	
	fileprivate init() {}
	
	public func results<SubjectComponent>(on subject: Shadow<SubjectComponent>) async throws -> AsyncStream<Shadow<ResultComponent>> {
		TODO.unimplemented
	}
	
}

extension Component {
	
	/// Returns a selector of components typed `Self`.
	public static func selector() -> TypeSelector<Self> {
		.init()
	}
	
}
