// Conifer © 2019–2020 Constantino Tsarouhas

/// A domain-specific element in the shadow graph, representing a component in a particular state.
///
/// Shadow elements are created and updated as part of the Conifer realisation process. The system invokes the component's `update(_:at:)` method when it needs a new or refreshed shadow element representing that component. Within that method, the component can navigate through the shadow graph to retrieve information thanecessary to create or update its own shadow element. The system records these accesses as dependencies of the shadow element. When any dependency changes, the shadow element is marked as needing updating and the system eventually invokes the `update(_:at:)` method again if the shadow element is still part of the graph before the next realisation pass.
public protocol ShadowElement {
	
	/// The element's location in the shadow graph, which also acts as the element's identity.
	var location: ShadowGraphLocation { get }
	
}
