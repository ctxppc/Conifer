// Conifer © 2019–2023 Constantino Tsarouhas

/// A conditional component; a component that renders one of two components.
///
/// Conifer clients that specialise `Component` should add a conditional conformance of `Either` to that protocol. For example, a web application framework that specialises `Component` as `Element` should add the following conformance:
///
///     extension Either : Element where First : Element, Second : Element {}
///
/// ## Shadow Semantics
///
/// A conditional component is replaced by the wrapped component in a shadow. A shadow never contains an `Either` but instead a `First` or `Second` at the same location. However, the structural identity of the first component differs from that of the second one, i.e., `Either.first(a)` is not equal to `Either.second(a)` for some component `a` for the purposes of component diffing.
public enum Either<First : Component, Second : Component> : Component {
	
	/// The first component is rendered.
	case first(First)
	
	/// The second component is rendered.
	case second(Second)
	
	// See protocol.
	public var body: Never { hasNoBody }
	
}

public func ??<First, Second>(first: First?, second: Second) -> Either<First, Second> {
	first.map { .first($0) } ?? .second(second)
}
