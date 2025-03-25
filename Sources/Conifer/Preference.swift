// Conifer © 2019–2025 Constantino Tsarouhas

/// A value that propagates up a component tree.
///
/// A component has a preference that is equal to, whichever applies first,
/// * the value directly assigned using `.preference(_:)`,
/// * the preference value produced by combining its children's preference values, or
/// * the `default` preference value.
public protocol Preference : Sendable {
	
	/// The default preference value.
	static var `default`: Self { get }
	
	/// Returns the combination of `self` and a preference value of a successor component at the same level.
	///
	/// - Invariant: `Self.default.combine(with: x)` equals `x` for all `x`.
	/// - Invariant: `x.combine(with: Self.default)` equals `x` for all `x`.
	func combine(with next: Self) async throws -> Self
	
}

extension Shadow {
	
	/// The preferences of the shadow, i.e., including preferences from child shadows.
	var preferences: Preferences {
		get async throws {
			try await cached(in: \.preferences) {	// TODO: Fine-grained dependency per preference type?
				try await directChildren()
					.asyncMap { try await $0.preferences }
					.reduce(into: Preferences()) { $0.merge($1) }
			}
		}
	}
	
	/// Assigns a preference value.
	func preference(_ preference: some Preference) async throws {
		try await set(\.assignedPreference, preference)
	}
	
}

fileprivate extension ShadowSnapshot {
	
	/// The preferences of the shadow, i.e., including preferences from child shadows, or `nil` if they have not been computed yet.
	var preferences: Preferences? {
		get { self[\.preferences] }
		set { self[\.preferences] = newValue }
	}
	
	/// The preference assigned by this shadow, or `nil` if the shadow does not represent a preference modifier.
	var assignedPreference: (any Preference)? {
		get { self[\.assignedPreference] }
		set { self[\.assignedPreference] = newValue }
	}
	
}

struct Preferences : Sendable {
	
	private var preferencesByType: [ObjectIdentifier : any Preference] = [:]
	
	subscript <P : Preference>(_ type: P.Type) -> P {
		get { preferencesByType[.init(type)] as! P? ?? .default }
		set { preferencesByType[.init(type)] = newValue }
	}
	
	mutating func merge(_ other: Preferences) {
		preferencesByType.merge(other.preferencesByType) { _, new in new }
	}
	
}
