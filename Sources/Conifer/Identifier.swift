// Conifer © 2019–2025 Constantino Tsarouhas

/// A value uniquely identifying a component or shadow among its siblings.
public typealias Identifier = Sendable & Hashable & Encodable

/// A type-erased value uniquely identifying a component or shadow among its siblings.
public struct AnyIdentifier : Identifier {
	
	// TODO: Remove type when any Equatable resp. any Hashable conform to Equatable resp. Hashable, or replace by such conformances.
	
	public init(_ base: some Identifier) {
		self.base = base
	}
	
	/// The underlying identifier.
	public let base: any Identifier
	
	// See protocol.
	public static func == (lhs: Self, rhs: Self) -> Bool {
		func equal<T : Equatable>(_ first: T, _ other: some Equatable) -> Bool {
			guard let other = other as? T else { return false }
			return first == other
		}
		return equal(lhs.base, rhs.base)
	}
	
	// See protocol.
	public func hash(into hasher: inout Hasher) {
		base.hash(into: &hasher)
	}
	
	// See protocol.
	public func encode(to encoder: any Encoder) throws {
		try base.encode(to: encoder)
	}
	
}
