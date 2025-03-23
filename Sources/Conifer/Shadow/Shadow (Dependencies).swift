// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit
import Foundation

extension Shadow {
	
	/// Records a shadow value read, recording it as a dependency of the shadow value being computed (if applicable).
	///
	/// - Requires: `graph === self.graph`. The parameter only exists to pass isolation.
	///
	/// - Parameters:
	///    - readValue: A reference to the shadow value being read.
	///    - graph: The shadow graph.
	func recordRead<V>(from readValue: ShadowValueReference<V>, graph: isolated ShadowGraph) {
		TODO.unimplemented
	}
	
	/// Records a shadow value write, invalidating any shadow values depending on it.
	///
	/// - Requires: `graph === self.graph`. The parameter only exists to pass isolation.
	///
	/// - Parameters:
	///    - writtenValue: A reference to the shadow value being written.
	///    - graph: The shadow graph.
	///
	/// - Throws: `DependencyError.cycle` if a cyclic dependency is detected.
	func recordWrite<V>(to writtenValue: ShadowValueReference<V>, graph: isolated ShadowGraph) throws(DependencyError) {
		for dependent in graph[location]!.dependentsByDependedShadowProperty[writtenValue.property] ?? [] {
			try dependent.invalidate(in: graph, trace: [.init(writtenValue)])
		}
	}
	
	/// Runs a given function, records any reads during its execution as dependencies of a given shadow property on `self`, and returns the value returned by the function.
	func recordDependencies<Value>(
		of property:	ShadowSnapshot.Property<Value?>,
		graph:			isolated ShadowGraph,
		compute:		sending () async throws -> Value
	) async throws -> Value {
		try await $shadowValueBeingComputed.withValue(.init(location: location, property: property), operation: compute)
	}
	
}

/// The shadow value being computed as part of the current `Shadow.cached(in:compute:)` call, or `nil` if no shadow value is being computed.
@TaskLocal
private var shadowValueBeingComputed: AnyShadowValueReference?

fileprivate extension ShadowSnapshot {
	
	/// A dictionary mapping each depended-on shadow property to dependent shadow value references that are to be invalidated when the depended-on shadow property changes.
	var dependentsByDependedShadowProperty: [AnyProperty : Set<AnyInvalidatableShadowValueReference>] {
		get { self[\.dependentsByDependedShadowProperty] ?? [:] }
		set { self[\.dependentsByDependedShadowProperty] = newValue }
	}
	
}

/// A shadow value reference that can be invalidated.
private protocol InvalidatableShadowValueReference : Sendable, Hashable {
	
	/// Invalidates `self` in a given graph and any shadow values that depend on it.
	///
	/// - Parameters:
	///    - graph: The graph.
	///    - trace: The shadow value references that are part of this dependency trace.
	///
	/// - Throws: `DependencyError.cycle` if `self` appears in `trace`.
	func invalidate(in graph: isolated ShadowGraph, trace: Set<AnyShadowValueReference>) throws(DependencyError)
	
}

extension ShadowValueReference : InvalidatableShadowValueReference where Value : OptionalProtocol {
	func invalidate(in graph: isolated ShadowGraph, trace: Set<AnyShadowValueReference>) throws(DependencyError) {
		guard !trace.contains(.init(self)) else { throw DependencyError.cycle }
		guard graph[location]![keyPath: property].take() != nil else { return }
		let dependents = graph[location]!.dependentsByDependedShadowProperty[property] ?? []
		let trace = trace.union([.init(self)])
		for dependent in dependents {
			try dependent.invalidate(in: graph, trace: trace)
		}
	}
}

private struct AnyInvalidatableShadowValueReference : InvalidatableShadowValueReference {
	
	var wrapped: any InvalidatableShadowValueReference
	
	static func == (lhs: Self, rhs: Self) -> Bool {
		func areEqual<T : InvalidatableShadowValueReference>(_ first: T, _ other: some InvalidatableShadowValueReference) -> Bool {
			guard let other = other as? T else { return false }
			return first == other
		}
		return areEqual(lhs.wrapped, rhs.wrapped)
	}
	
	func hash(into hasher: inout Hasher) {
		wrapped.hash(into: &hasher)
	}
	
	func invalidate(in graph: isolated ShadowGraph, trace: Set<AnyShadowValueReference>) throws(DependencyError) {
		try wrapped.invalidate(in: graph, trace: trace)
	}
	
}

public enum DependencyError : LocalizedError {
	case cycle
	public var errorDescription: String? {
		switch self {
			case .cycle: "Dependency cycle detected"
		}
	}
}
