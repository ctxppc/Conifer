# ``Conifer``

## Overview
*Conifer* is a framework for building and manipulating declarative, contextual, complex tree structures in Swift. It provides a domain-specific language for expressing hierarchical data (e.g., user interface elements) as well as tools to conveniently transform this data (e.g., to HTML elements).

## Topics

### Components
- <doc:Component-Protocols>
- ``Component``
- ``Either``
- ``Empty``
- ``ForEach``
- ``Group``
- ``Modified``
- ``??(_:_:)``
- ``ComponentBuilder``

### Shadows
- ``makeShadow(over:)``
- ``Shadow``
- ``OwnedShadow``
- ``UnownedShadow``
- ``ShadowSnapshot``
- ``ShadowGraph``

### Dynamic Properties
- ``DynamicProperty``
- ``MutableDynamicProperty``
- ``State``
- ``Binding``
- ``Contextual``
- ``Preferred``
- ``StructuralIdentifier``

### Modifiers
- ``Modifier``

### Preferences
- ``Preference``

### Other
- ``Context``
- ``Identifier``
- ``AnyIdentifier``
- ``DependencyError``
