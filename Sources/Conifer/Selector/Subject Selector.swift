// Conifer © 2019–2023 Constantino Tsarouhas

/// A selector that selects the subject.
public struct SubjectSelector {}

extension SubjectSelector : Selector {
	public func selection(subject: UntypedShadow) -> AsyncStream<UntypedShadow> {
		[subject].makeAsyncStream()
	}
}

extension Selector where Self == SubjectSelector {
	
	/// Returns a selector that selects the subject.
	static var `self`: Self {
		.init()
	}
	
}
