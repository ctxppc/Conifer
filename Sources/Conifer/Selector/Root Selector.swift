// Conifer © 2019–2023 Constantino Tsarouhas

/// A selector that selects the root component.
public struct RootSelector {}

extension RootSelector : Selector {
	public func selection(root: UntypedShadow) -> AsyncStream<UntypedShadow> {
		[root].makeAsyncStream()
	}
}

extension Selector where Self == RootSelector {
	
	/// Returns a selector that selects the root component.
	static var root: Self {
		.init()
	}
	
}
