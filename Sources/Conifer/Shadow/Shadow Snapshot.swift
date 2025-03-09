// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit

/// A container of stored shadow properties associated with a component.
///
/// A stored shadow property is a property associated with a component whose storage is managed by a shadow graph. A snapshot is container of such properties associated with a single component.
///
/// To declare a stored shadow property, declare a property in an extension of this type whose getter resp. setter returns resp. assigns `self[keyPath]` where `keyPath` is the key path of the shadow property. `self[keyPath]` returns `nil` when the property does not have an assigned value; you may choose to provide a default value instead.
///
/// 	extension ShadowSnapshot {
///			var prefersPrettyPrint: Bool {
///				get { self[\.prefersPrettyPrint] ?? true }
///				get { self[\.prefersPrettyPrint] = newValue }
///			}
/// 	}
///
/// Stored shadow properties can be directly accessed on a shadow. Unlike accessing a stored shadow property on a snapshot, accessing a stored shadow property through a shadow is an asynchronous operation.
///
/// 	let myShadow: any Shadow = …
/// 	let printPrettily = await myShadow.prefersPrettyPrint
///
/// To (re)assign a stored shadow property on a shadow, use `set(_:_:)`.
///
/// 	await myShadow.set(\.prefersPrettyPrint, false)
///
/// A snapshot represents a shadow at a fixed time. Changes to a snapshot, as opposed to changes on a shadow, do not propagate to the shadow graph.
///
/// A computed shadow property is a property associated with a component that depends on shadow properties associated with other components or other external sources of truth. Declare such properties on `Shadow` instead of `ShadowSnapshot`. A computed shadow property should use a stored shadow property (declared on `ShadowSnapshot`) to store cached results.
///
/// Shadow graphs are actors. Properties must therefore be `Sendable` since they often cross a shadow graph's isolation boundary.
public struct ShadowSnapshot : Sendable {
	
	/// Creates a snapshot with only the subject property set.
	init(subject: any Component) {
		self.subject = subject
	}
	
	/// The snapshot's values, keyed by property key path.
	private var values: [Property : any Sendable] = [:]
	typealias Property = PartialKeyPath<Self> & Sendable
	
	/// Accesses a non-optional shadow property with a default value.
	///
	/// A `nil` value in this subscript operator represents the absence of an assigned value. The shadow property's getter provides a default value in that case, e.g., `self[\.prefersPrettyPrint] ?? true` for a shadow property of type `Bool`.
	public subscript <Value : Sendable>(keyPath: WritableKeyPath<Self, Value> & Sendable) -> Value? {
		get { values[keyPath] as! Value? }
		set { values[keyPath] = newValue }
	}
	
	/// Accesses an optional shadow property.
	///
	/// A `nil` value in this subscript operator represents the absence of an assigned value.
	public subscript <Value : Sendable>(keyPath: WritableKeyPath<Self, Value?> & Sendable) -> Value? {
		get { values[keyPath] as! Value? }
		set { values[keyPath] = newValue }
	}
	
}

extension ShadowSnapshot {
	
	/// The rendered subject.
	///
	/// - Invariant: Every dynamic property in `subject` has been updated at least once.
	var subject: any Component {
		get { self[\.subject] !! "Shadow snapshot with unrendered component" }
		set { self[\.subject] = newValue }
	}
	
}
