// Conifer © 2019–2025 Constantino Tsarouhas

@_spi(Reflection) import ReflectionMirror

extension PartialKeyPath {
	
	/// Returns key paths from `Root` to each stored property on `Root`.
	static func allStoredPropertyKeyPaths() -> [PartialKeyPath & Sendable] {
		var keyPaths = [PartialKeyPath & Sendable]()
		let success = _forEachFieldWithKeyPath(of: Root.self) { _, keyPath in
			keyPaths.append(keyPath as! PartialKeyPath & Sendable)
			return true
		}
		precondition(success, "Could not determine all key paths from \(Root.self)")
		return keyPaths
	}
	
}
