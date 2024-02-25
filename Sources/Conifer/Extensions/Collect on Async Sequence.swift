// Conifer © 2019–2024 Constantino Tsarouhas

extension AsyncSequence {
	
	/// Collects the elements of `self` into an array.
	func collect() async rethrows -> [Element] {
		try await reduce(into: []) {
			$0.append($1)
		}
	}
	
}
