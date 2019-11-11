//
//  CLTokenizer.swift
//  CLCodable
//
//  Created by Zapko on 2019-11-10.
//

import Foundation


public indirect enum CLToken: Equatable {
    case cons(CLToken, CLToken)
    case number(String)
    case literal(String)
    case structure(name: String, slots: [String : CLToken])
}


internal struct CLTokenizer {


    // MARK: - Private state

    private var iterator: String.UnicodeScalarView.Iterator
    private var cachedScalar: UnicodeScalar?


    // MARK: - Initializer
    
    init(clView: String) {
        iterator = clView.unicodeScalars.makeIterator()
    }

    mutating func nextToken() throws -> CLToken? {

        while let char = nextScalar() {

            switch char {
            case " ", "\n", "\t", "\r":
                continue

            case "#":

                switch nextScalar() {
                case "s", "S":
                    return try structToken()
                default:
                    let message = "Found '\(char)' after '#' on root level"
                    throw CLReadError.dataCorrupted(.init(message))
                }

            case "\"":
                return try literalToken()

            case "0"..."9", ",", ".", "_":
                return try numberToken(startingWith: char)

            default:
                let message = "Found '\(char)' on root level"
                throw CLReadError.dataCorrupted(.init(message))
            }
        }

        return nil
    }


    // MARK: - Private Methods

    private mutating func nextScalar() -> UnicodeScalar? {
        guard let cached = cachedScalar else {
            return iterator.next()
        }

        cachedScalar = nil
        return cached
    }

    mutating func structToken() throws -> CLToken {

        guard let firstSymbol = nextScalar(), firstSymbol == "(" else {
            let message = "Malformed struct"
            throw CLReadError.dataCorrupted(.init(message))
        }

        var nameDefined = false
        var structName = ""
        var slots: [String : CLToken] = [:]
        
        while let char = nextScalar() {
            switch (char, nameDefined) {
            case ( " ", false),
                 ("\n", false),
                 ("\t", false),
                 ("\r", false):
                nameDefined = true

            case ( " ", true),
                 ("\n", true),
                 ("\t", true),
                 ("\r", true):
                continue

            case (_, false):
                structName.unicodeScalars.append(char)

            case (":", true):
                let fieldName = try readFieldName()

                guard slots[fieldName] == nil else {
                    let message = "Multiple values for field '\(fieldName)'"
                    throw CLReadError.dataCorrupted(.init(message))
                }

                slots[fieldName] = try nextToken()

            case (")", true):
                return .structure(name: structName, slots: slots)

            case (_, true):
                let message = "Malformed struct. Name '\(structName)'. Slots '\(slots)'. Received '\(char)'"
                throw CLReadError.dataCorrupted(.init(message))
            }
        }

        let message = "Non-terminated structure"
        throw CLReadError.dataCorrupted(.init(message))
    }

    mutating func readFieldName() throws -> String {

        var fieldName = ""

        while let char = nextScalar() {
            switch char {
            case " ": return fieldName
            default: fieldName.unicodeScalars.append(char)
            }
        }

        return fieldName
    }

    mutating func literalToken() throws -> CLToken {

        var escaped = false
        var literal = ""

        while let char = nextScalar() {
            switch (char, escaped) {
            case (_, true):
                literal.unicodeScalars.append(char)
                escaped = false

            case ("\\", false):
                escaped = true

            case ("\"", false):
                return .literal(literal)

            case (_, false):
                literal.unicodeScalars.append(char)
            }
        }

        let message = "Non-terminated string literal"
        throw CLReadError.dataCorrupted(.init(message))
    }

    mutating func numberToken(startingWith first: UnicodeScalar) throws -> CLToken {

        var token = String(first)

        while let char = nextScalar() {

            switch char {
            case "0"..."9", ",", ".", "_":
                token.unicodeScalars.append(char)

            case " ", "\t", "\n", "\r", ")":
                cachedScalar = char
                return .number(token)

            default:
                let message = "Malformed number. Contains: '\(char)'"
                throw CLReadError.dataCorrupted(.init(message))
            }
        }

        let message = "Non-terminated number '\(token)'"
        throw CLReadError.dataCorrupted(.init(message))
    }
}
