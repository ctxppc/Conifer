// Spin © 2019–2024 Constantino Tsarouhas

import Algorithms

extension String {
	
	/// Returns the result of splitting `self` by uppercase characters, merging words that are fully uppercased.
	///
	/// Examples:
	/// - "MyNameIsJohn" is split into "My", "Name", "Is", and "John"
	/// - "thisURLContains3QuestionMarks" is split into "this", "URL", "Contains3", "Question", and "Marks"
	public func splitByTitlecasedWords() -> [String] {
		
		guard let first else { return [] }
		
		var words = ["\(first)"]
		for (prev, current) in adjacentPairs() {
			if !prev.isUppercase && current.isUppercase {
				words.append("\(current)")
			} else {
				words.append(words.removeLast().appending(current))
			}
		}
		
		return words
		
	}
	
}
