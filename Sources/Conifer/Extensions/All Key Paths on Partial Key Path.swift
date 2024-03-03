// Conifer © 2019–2024 Constantino Tsarouhas

@_spi(Reflection) import ReflectionMirror

extension PartialKeyPath {
	
	/// Returns all key paths from `Root` to properties on `Root`.
	static func allKeyPaths() -> [PartialKeyPath] {
		var keyPaths = [PartialKeyPath]()
		let success = _forEachFieldWithKeyPath(of: Root.self) { _, keyPath in
			keyPaths.append(keyPath)
			return true
		}
		precondition(success, "Could not determine all key paths from \(Root.self)")
		return keyPaths
	}
	
}
