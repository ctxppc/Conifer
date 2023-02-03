// Conifer © 2019–2023 Constantino Tsarouhas

extension Vertex {
	
	/// Accesses a vertex at given location.
	public subscript (location: ShadowGraphLocation) -> Self {
		
		get {
			guard let (head, tail) = location.entering() else { return self }
			return self[head][tail]
		}
		
		set {
			if let (head, tail) = location.entering() {
				self[head][tail] = newValue
			} else {
				self = newValue
			}
		}
		
	}
	
	/// Accesses a child vertex with given identifier.
	public subscript (identifier: AnyHashable) -> Vertex {
		
		get {
			switch contents {
				case .structure(childrenByIdentifier: let childrenByIdentifier):	return childrenByIdentifier[identifier] ?? .empty
				case .artefact(_, childrenByIdentifier: let childrenByIdentifier):	return childrenByIdentifier[identifier] ?? .empty
				case .hidden:														return .empty
			}
		}
		
		set {
			switch contents {
				
				case .structure(childrenByIdentifier: var childrenByIdentifier):
				childrenByIdentifier[identifier] = newValue
				contents = .structure(childrenByIdentifier: childrenByIdentifier)
				
				case .artefact(let artefact, childrenByIdentifier: var childrenByIdentifier):
				childrenByIdentifier[identifier] = newValue
				contents = .artefact(artefact, childrenByIdentifier: childrenByIdentifier)
				
				case .hidden:
				return	// hidden child can be discarded
				
			}
		}
		
	}
	
}
