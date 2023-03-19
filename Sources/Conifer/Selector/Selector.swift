// Conifer © 2019–2023 Constantino Tsarouhas

/// A value that selects (untyped) components for a given root.
public protocol Selector : Sendable {
	
	/// Returns selected components for `root`.
	func selection(subject: UntypedShadow) -> Selection
	associatedtype Selection : AsyncSequence where Selection.Element == UntypedShadow
	
}
