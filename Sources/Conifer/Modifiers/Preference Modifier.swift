// Conifer © 2019–2024 Constantino Tsarouhas

extension Component {
	
	/// Sets the preference value.
	public func preference(_ preference: some Preference) -> Modified<Self, some Modifier> {
		modifier(PreferenceModifier(preference: preference))
	}
	
}

private struct PreferenceModifier<PreferenceType : Preference> : Modifier, Sendable {
	
	/// The contextual value.
	let preference: PreferenceType
	
	// See protocol.
	func update(_ shadow: some Shadow) async {
		await shadow.update(preference)
	}
	
}
