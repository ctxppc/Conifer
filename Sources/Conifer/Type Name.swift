// Spin © 2019–2024 Constantino Tsarouhas

/// A name indicating the type of an element, attribute, etc.
public protocol TypeName : Sendable, ExpressibleByStringInterpolation where StringLiteralType == String {
	
	/// Creates a name with given already validated source.
	///
	/// - Note: This method does not perform validation. Prefer using `init(stringLiteral:)` and `init(type:)` instead.
	init(validatedSource: TypeNameSource)
	
	/// The source of the name.
	var source: TypeNameSource { get }
	
	/// The pattern that names of this type conform to.
	static var pattern: Regex<Substring> { get }
	
}

public enum TypeNameSource : Sendable {
	case literal(String)
	case typeName(String)
}

extension TypeName {
	
	/// Creates an element name.
	///
	/// - Requires: `name` is a valid name, i.e., matches `Self.pattern`.
	public init(stringLiteral name: String) {
		precondition(try! Self.pattern.wholeMatch(in: name) != nil, "'\(name)' is not a valid \(Self.self)")
		self.init(validatedSource: .literal(name))
	}
	
	/// Creates an element name based on a given type.
	public init<T>(type: T.Type) {
		self.init(validatedSource: .typeName("\(type)"))
	}
	
	/// Returns the encoded name.
	public func encoded(transform: NameTransform) -> String {
		switch source {
			case .literal(let name):	name
			case .typeName(let name):	transform(name)
		}
	}
	
}

public protocol NameTransform {
	
	/// Transforms given name.
	func callAsFunction(_ original: String) -> String
	
}

extension NameTransform {
	
	/// Returns a transform that doesn't change names.
	public static func identity() -> Self where Self == IdentityNameTransform {
		.init()
	}
	
	/// Returns a transform which converts names to snake-case, i.e., lower-cased with (originally titlecased) words connected by hyphens.
	public static func snakecase() -> Self where Self == SnakecaseNameTransform {
		.init()
	}
	
	/// Returns a transform which removes given suffix (for names that consist of a non-empty prefix and given suffix), then converts names to snake-case, i.e., lower-cased with (originally titlecased) words connected by hyphens.
	public static func snakecase(suffix: String) -> Self where Self == SuffixedSnakecaseNameTransform {
		.init(suffix: suffix)
	}
	
	/// Returns a transform defined by a given function.
	public static func custom(_ transform: @escaping Self.Transform) -> Self where Self == CustomNameTransform {
		.init(transform: transform)
	}
	
}

public struct IdentityNameTransform : NameTransform {
	
	// See protocol.
	public func callAsFunction(_ original: String) -> String {
		original
	}
	
}

public struct SnakecaseNameTransform : NameTransform {
	
	// See protocol.
	public func callAsFunction(_ original: String) -> String {
		original
			.splitByTitlecasedWords()
			.joined(separator: "-")
			.lowercased()
	}
	
}

public struct SuffixedSnakecaseNameTransform : NameTransform {
	
	/// The suffix.
	public var suffix: String
	
	// See protocol.
	public func callAsFunction(_ original: String) -> String {
		
		var trimmed = original
		if original.hasSuffix(suffix) {
			trimmed.removeLast(suffix.count)
		}
		
		return trimmed
			.splitByTitlecasedWords()
			.joined(separator: "-")
			.lowercased()
		
	}
	
}

public struct CustomNameTransform : NameTransform {
	
	/// A function to transforms a name.
	public let transform: Transform
	public typealias Transform = (String) -> String
	
	// See protocol.
	public func callAsFunction(_ original: String) -> String {
		transform(original)
	}
	
}
