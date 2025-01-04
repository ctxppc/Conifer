// Conifer © 2019–2025 Constantino Tsarouhas

@_spi(Reflection) import ReflectionMirror

extension PartialKeyPath {
	
	/// Returns key paths from `Root` to each stored property on `Root`.
	static func allStoredPropertyKeyPaths() -> [PartialKeyPath] {
		var keyPaths = [PartialKeyPath]()
		let success = _forEachFieldWithKeyPath(of: Root.self) { _, keyPath in
			keyPaths.append(keyPath)
			return true
		}
		precondition(success, "Could not determine all key paths from \(Root.self)")
		return keyPaths
	}
	
}
