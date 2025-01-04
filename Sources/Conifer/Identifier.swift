// Conifer © 2019–2025 Constantino Tsarouhas

public typealias Identifier = Hashable & Encodable & Sendable

public struct AnyIdentifier : Hashable, Encodable, @unchecked Sendable {	// AnyHashable and encode functions are conditionally Sendable
	
	public init(_ identifier: some Identifier) {
		hashable = .init(identifier)
		encode = identifier.encode(to:)
	}
	
	public func hash(into hasher: inout Hasher) {
		hashable.hash(into: &hasher)
	}
	
	public static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.hashable == rhs.hashable
	}
	
	private let hashable: AnyHashable
	
	public func encode(to encoder: any Encoder) throws {
		try self.encode(encoder)
	}
	
	private let encode: (any Encoder) throws -> ()
	
}
