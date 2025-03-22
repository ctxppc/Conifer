// Conifer © 2019–2025 Constantino Tsarouhas

import Foundation

/// An acyclic directed graph tracking dependencies between elements.
///
/// An element `a` *depends on* another element `b` if updating `b` requires an update to `a` before `a` can be meaningfully used. This dependency is expressed to the graph as `addDependency(of: a, to: b)`.
///
/// Every element in the graph, including elements not known to graph, is either invalid or up-to-date. An element starts as invalid until it is marked as updated using `markAsUpdated(_:)`, at which points the graph also invalidates all elements that depend on that element either directly or indirectly. An element can be invalidated manually using `invalidate(_:)`, e.g., when external circumstances have caused it require an update in the future.
///
/// A dependency graph detects cyclic dependencies when an element involved in such a dependency is invalidated. When such a cycle is detected, the graph throws an error and should no longer be used.
@available(*, deprecated)
struct DependencyGraph<Element : Hashable & Sendable> : Hashable, Sendable {
	
	/// The known valid elements.
	private var valid = Set<Element>()
	
	/// A dictionary mapping dependers to their dependents.
	///
	/// When a depender is invalidated, the graph also (recursively) invalidates its dependents.
	private var dependentsByDepender = [Element : Set<Element>]()
	
	/// Returns a Boolean value indicating whether a given element is known to be valid.
	///
	/// This method returns `false` if the graph does not know `element`.
	func isValid(_ element: Element) -> Bool {
		valid.contains(element)
	}
	
	/// Marks a given element as updated, invalidating all elements that depend on it.
	///
	/// - Postcondition: `isValid(element)`.
	/// - Postcondition: Every element `e` that transitively depends on `element`, `!isValid(e)`.
	///
	/// - Throws: `DependencyError.cyclicDependency` if `element` is part of a cycle in the graph.
	mutating func markAsUpdated(_ element: Element) throws/*(DependencyError)*/ {
		valid.insert(element)
		for dependent in dependentsByDepender[element] ?? [] {
			try invalidate(dependent, cause: element)
		}
	}
	
	/// Marks a given element and all elements that depend on it as invalid.
	///
	/// - Postcondition: !`isValid(element)`.
	/// - Postcondition: For every `e` for which `addDependency(of: e, to: element)` is invoked, `!isValid(e)`.
	///
	/// - Throws: `Error.cyclicDependency` if `element` is part of a cycle in the graph.
	mutating func invalidate(_ element: Element) throws/*(DependencyError)*/ {
		try invalidate(element, cause: element)
	}
	
	/// Marks a given element and all elements that depend on it as invalid.
	///
	/// - Postcondition: !`isValid(element)`.
	/// - Postcondition: For every `e` for which `addDependency(of: e, to: element)` is invoked, `!isValid(e)`.
	///
	/// - Throws: `DependencyError.cyclicDependency` if `element` is part of a cycle in the graph.
	private mutating func invalidate(_ element: Element, cause: Element) throws/*(DependencyError)*/ {	// TODO: Use typed throws when compiler issue is fixed.
		let previousValid = valid.remove(element)
		guard previousValid != nil else { return }
		for dependent in dependentsByDepender[element] ?? [] {
			guard dependent != cause else { throw DependencyError.cyclicDependency(cycle: [dependent]) }
			do {
				try invalidate(dependent, cause: cause)
			} catch DependencyError.cyclicDependency(cycle: let cycle) {
				throw DependencyError.cyclicDependency(cycle: cycle.appending(dependent))
			}
		}
	}
	
	/// Adds a dependency between the first element to the second element.
	///
	/// This method does nothing if the graph is already tracking this dependency.
	///
	/// - Postcondition: If `!isValid(depender)`, then `!isValid(dependent)`.
	///
	/// - Throws: `DependencyError.cyclicDependency` if `!isValid(depender)` and `dependent` is part of a cycle in the graph.
	mutating func addDependency(of dependent: Element, to depender: Element) throws/*(DependencyError)*/ {
		dependentsByDepender[depender, default: []].insert(dependent)
		if !isValid(depender) {
			try invalidate(dependent)
		}
	}
	
	/// Removes a dependency between the first element to the second element.
	///
	/// This method does nothing if the graph is not tracking this dependency.
	mutating func removeDependency(of dependent: Element, to depender: Element) {
		dependentsByDepender[depender, default: []].remove(dependent)
	}
	
	enum DependencyError : LocalizedError {
		
		/// An error indicating a cyclic dependency.
		case cyclicDependency(cycle: [Element])
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .cyclicDependency(let cycle):
				"Dependency cycle detected: \(cycle)"
			}
		}
		
	}
	
}
