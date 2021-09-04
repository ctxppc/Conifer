// Conifer © 2019–2021 Constantino Tsarouhas

import Collections

extension Vertex : RandomAccessCollection, MutableCollection {
	
	public var startIndex: Index {
		switch contents {
			case .structure(childrenByIdentifier: let c):	return .init(baseIndex: c.values.startIndex)
			case .artefact(_, childrenByIdentifier: let c):	return .init(baseIndex: c.values.startIndex)
			case .hidden:									return .invalid
		}
	}
	
	public var endIndex: Index {
		switch contents {
			case .structure(childrenByIdentifier: let c):	return .init(baseIndex: c.values.endIndex)
			case .artefact(_, childrenByIdentifier: let c):	return .init(baseIndex: c.values.endIndex)
			case .hidden:									return .invalid
		}
	}
	
	public subscript (index: Index) -> Vertex {
		
		get {
			switch contents {
				case .structure(childrenByIdentifier: let c):	return c.values[index.baseIndex]
				case .artefact(_, childrenByIdentifier: let c):	return c.values[index.baseIndex]
				case .hidden:									preconditionFailure("Index out of bounds")
			}
		}
		
		set {
			switch contents {
				
				case .structure(childrenByIdentifier: var c):
				c.values[index.baseIndex] = newValue
				contents = .structure(childrenByIdentifier: c)
				
				case .artefact(let a, childrenByIdentifier: var c):
				c.values[index.baseIndex] = newValue
				contents = .artefact(a, childrenByIdentifier: c)
				
				case .hidden:
				preconditionFailure("Index out of bounds")
				
			}
		}
		
	}
	
	public struct Index : Comparable, Strideable {
		
		/// The invalid index for vertices without children.
		fileprivate static let invalid = Self(baseIndex: 0)
		
		/// The underlying index.
		fileprivate let baseIndex: BaseIndex
		fileprivate typealias BaseIndex = OrderedDictionary<AnyHashable, Vertex>.Values.Index
		
		// See protocol.
		public static func < (first: Self, latter: Self) -> Bool {
			first.baseIndex < latter.baseIndex
		}
		
		// See protocol.
		public func distance(to other: Self) -> Int {
			self.baseIndex.distance(to: other.baseIndex)
		}
		
		// See protocol.
		public func advanced(by n: Int) -> Self {
			.init(baseIndex: self.baseIndex.advanced(by: n))
		}
		
	}
	
}
