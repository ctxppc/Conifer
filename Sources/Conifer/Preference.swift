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
	func combined(with next: Self) -> Self
	
}

extension Shadow {
	
	func preference<P : Preference>(ofType type: P.Type) async throws -> P {
		try await cached(in: \.preferences[PreferenceType<P>()]) {
			if let preference = await self.assignedPreferences[PreferenceType<P>()] {
				return preference
			}
			let childPreferences = try await directChildren()
				.asyncMap { try await $0.preference(ofType: P.self) }
			guard let (head, tail) = childPreferences.splittingFirst() else { return .default }
			return tail.reduce(head) { $0.combined(with: $1) }
		}
	}
	
	/// Assigns a preference value.
	func setPreference<P : Preference>(_ preference: P) async throws {
		try await update(\.assignedPreferences) {
			$0[PreferenceType<P>()] = preference
		}
	}
	
}

fileprivate extension ShadowSnapshot {
	
	/// The (partially) computed preferences of the shadow, i.e., including preferences from child shadows.
	var preferences: Preferences {
		get { self[\.preferences] ?? .init() }
		set { self[\.preferences] = newValue }
	}
	
	/// The preferences assigned by this shadow, or a default set if the shadow does not represent a preference modifier.
	var assignedPreferences: Preferences {
		get { self[\.assignedPreferences] ?? .init() }
		set { self[\.assignedPreferences] = newValue }
	}
	
}

private struct Preferences : Sendable {
	
	private var preferencesByType: [ObjectIdentifier : any Preference] = [:]
	
	/// Accesses a preference of a given type, with unknown or unassigned preferences represented by `nil`.
	subscript <P : Preference>(_: PreferenceType<P>) -> P? {
		get { preferencesByType[.init(P.self)] as! P? }
		set { preferencesByType[.init(P.self)] = newValue }
	}
	
}

private struct PreferenceType<P : Preference> : Sendable, Hashable {
	
	static func == (lhs: Self, rhs: Self) -> Bool {
		true
	}
	
	func hash(into hasher: inout Hasher) {
		ObjectIdentifier(P.self).hash(into: &hasher)
	}
	
}
