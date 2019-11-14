//
// Created by Zapko on 2019-11-13.
//

import Foundation

/// Simplified kebab-case to camelCase conversion
func styleFromCLToSwift(name: String) -> String {
    name
        .components(separatedBy: "-")
        .map { $0.capitalized }
        .joined()
}

/// Simplified camelCase to kebab-case conversion
func styleFromSwiftToCL(name: String) -> String {

    var words: [String] = []
    var tokenizer = WordsTokenizer(string: name)

    while let word = tokenizer.nextWord() {
        words.append(word)
    }

    return words
        .map { $0.uppercased() }
        .joined(separator: "-")
}

private struct WordsTokenizer {

    private var iterator:   String.Iterator
    private var cachedChar: Character?

    init(string: String) {
        iterator = string.makeIterator()
    }

    mutating func nextWord() -> String? {

        var word = ""

        while let char = nextChar() {

            // Treating non-characters as word boundaries
            guard char.isUppercase || char.isLowercase else {
                if word.isEmpty { continue    }
                else            { return word }
            }

            guard let last = word.last else {
                word.append(char)
                continue
            }

            switch (last.isUppercase, char.isUppercase) {
            case (true, true):
                word.append(char)

            case (true, false):
                word.append(char)

            case (false, true):
                cachedChar = char
                return word

            case (false, false):
                word.append(char)
            }
        }

        return word.isEmpty ? nil : word
    }

    mutating func nextChar() -> Character? {

        if let cached = cachedChar {
            cachedChar = nil
            return cached
        } else {
            return iterator.next()
        }
    }
}
