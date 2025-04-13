// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

/// A value that propagates up a component tree.
///
/// A component has a preference that is equal to, whichever applies first,
/// * the value directly assigned using `.preference(_:)`,
/// * the preference value produced by combining its children's preference values, or
/// * the `default` preference value.
public protocol Preference : Sendable {
	
	/// The default preference value.
	static var `default`: Self { get }
	
	/// Returns the combination of `self` and a given preference value of a successor component at the same level.
	///
	/// - Invariant: `Self.default.combine(with: x)` equals `x` for all `x`.
	/// - Invariant: `x.combine(with: Self.default)` equals `x` for all `x`.
	func combined(with next: Self) -> Self
	
}

extension Shadow {
	
	/// The preferences of the shadow, i.e., including preferences from child shadows.
	var preferences: Preferences {
		get async throws {
			try await cached(in: \.preferences) {	// TODO: Fine-grained dependency per preference type?
				let descendantPreferences = try await directChildren()
					.asyncMap { try await $0.preferences }
					.reduce(into: Preferences()) { $0.combine(with: $1) }
				return with(await self.assignedPreferences) {
					$0.inherit(from: descendantPreferences)
				}
			}
		}
	}
	
	/// Assigns a preference value.
	func preference<P : Preference>(_ preference: P) async throws {
		try await update(\.assignedPreferences) {
			$0[P.self] = preference
		}
	}
	
}

fileprivate extension ShadowSnapshot {
	
	/// The preferences of the shadow, i.e., including preferences from child shadows, or `nil` if they have not been computed yet.
	var preferences: Preferences? {
		get { self[\.preferences] }
		set { self[\.preferences] = newValue }
	}
	
	/// The preferences assigned by this shadow, or a default set if the shadow does not represent a preference modifier.
	var assignedPreferences: Preferences {
		get { self[\.assignedPreferences] ?? .init() }
		set { self[\.assignedPreferences] = newValue }
	}
	
}

struct Preferences : Sendable {
	
	private var preferencesByType: [ObjectIdentifier : any Preference] = [:]
	
	subscript <P : Preference>(_ type: P.Type) -> P {
		get { preferencesByType[.init(type)] as! P? ?? .default }
		set { preferencesByType[.init(type)] = newValue }
	}
	
	/// Combines `self` with a given set of preferences of a successor component at the same level.
	fileprivate mutating func combine(with other: Preferences) {
		
		func combined<P : Preference>(_ first: P, with other: some Preference) -> any Preference {
			guard let other = other as? P else { fatalError("Expected same-key preference to be of same type \(P.self)") }
			return first.combined(with: other)
		}
		
		preferencesByType.merge(other.preferencesByType) { combined($0, with: $1) }
		
	}
	
	/// Adds missing preferences from a given set of preferences from descendants.
	fileprivate mutating func inherit(from descendantPreferences: Preferences) {
		preferencesByType.merge(descendantPreferences.preferencesByType) { p, _ in p }
	}
	
}
