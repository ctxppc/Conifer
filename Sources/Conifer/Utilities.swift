// Conifer © 2019–2021 Constantino Tsarouhas

import DepthKit

typealias TODO = DepthKit.TODO

/// Modifies given initial value using given modification function, then returns the modified value.
///
/// - Parameters:
///   - initialValue: The initial value.
///   - modify: A function that modifies the initial value.
///
/// - Returns: The resulting value after executing `modify` on `initialValue`.
public func with<V>(_ initialValue: V, modify: (inout V) throws -> ()) rethrows -> V {
	var value = initialValue
	try modify(&value)
	return value
}
