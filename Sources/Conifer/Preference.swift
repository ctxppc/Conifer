// Conifer © 2019–2025 Constantino Tsarouhas

/// A value that propagates up a component tree.
///
/// A component has a preference that is equal to, whichever applies first,
/// * the value directly assigned using `.preference(_:)`,
/// * the preference value merged from its children's preference values, or
/// * the `default` preference value.
public protocol Preference : Sendable {
	
	/// The default preference value.
	static var `default`: Self { get }
	
	/// Returns the combination of `self` and a preference value of a successor component at the same level.
	///
	/// - Invariant: `Self.default.merged(with: x)` equals `x` for all `x`.
	/// - Invariant: `x.merged(with: Self.default)` equals `x` for all `x`.
	func merged(with next: Self) async throws -> Self
	
}

extension Shadow {
	
	/// Returns the preference of a given type of `self`.
	func preference<P : Preference>(ofType type: P.Type) async throws -> P {
		if let preference = await element(ofType: type) {
			return preference
		} else {
			return try await children(ofType: (any Shadow).self)
				.map { try await $0.preference(ofType: type) }
				.reduce(P?.none) { try await $0?.merged(with: $1) ?? $1}
				?? P.default
		}
	}
	
}
