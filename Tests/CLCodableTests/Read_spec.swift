//
//  Parser_spec.swift
//  cl-codableTests
//
//  Created by Zapko on 2019-11-03.
//  Copyright © 2019 Zababako. All rights reserved.
//

import XCTest
@testable import CLCodable

class Read_spec: XCTestCase {
    
    
    // MARK: - Structures definition
    
    struct Person: InitiableWithStringsDictionary {
        let name: String
        let age:  Int

        // TODO: code-generate this kind of initializers
        init(dictionary: [String : String]) throws {

            guard let name = dictionary["name"] else {
                throw ParsingError.missingValue(field: "name")
            }

            self.name = name

            guard let ageRaw = dictionary["age"] else {
                throw ParsingError.missingValue(field: "age")
            }

            guard let age = Int(ageRaw) else {
                throw ParsingError.unreadableValue(field: "age", value: ageRaw, type: Int.self)
            }

            self.age = age
        }
    }
    
    struct Couple: InitiableWithStringsDictionary {
        let one: Person
        let two: Person
        
        init(dictionary: [String : String]) throws {

            guard let one = dictionary["one"] else {
                throw ParsingError.missingValue(field: "one")
            }

            self.one = try read(clView: one)

            guard let two = dictionary["two"] else {
                throw ParsingError.missingValue(field: "two")
            }

            self.two = try read(clView: two)
        }
    }

    
    // MARK: - Test suit

    func test_Reading_simple_structure() throws {

        let person: Person = try read(
            clView: "#s(person :age 30 :name \"Bob\")"
        )

        XCTAssertEqual(person.name, "Bob")
        XCTAssertEqual(person.age, 30)
    }

    func test_Reading_structure_with_screened_quotes() throws {

        let person: Person = try read(
            clView: "#s(person :age 30 :name \"Bob \\\"the Builder\\\"\")"
        )

        XCTAssertEqual(person.name, "Bob \"the Builder\"")
        XCTAssertEqual(person.age, 30)
    }
    
    func test_Reading_nested_structure() throws {
     
        let couple: Couple = try read(
            clView: """
                    #s(couple
                        :one #s(person :age 30 :name "Bob")
                        :two #s(person :age 29 :name "Felicia"))
                    """
        )
        
        XCTAssertEqual(couple.one.name, "Bob")
        XCTAssertEqual(couple.one.age, 30)
        XCTAssertEqual(couple.two.name, "Felicia")
        XCTAssertEqual(couple.two.age, 29)
    }

    // TODO: test transformation from kebab to camel cases for property names
    // TODO: test upper cased format of CL structures
    // TODO: test lists transformation into arrays
    // TODO: add performance tests

    // TODO: test encoding of simple structs
    // TODO: test encoding of nested structs
    // TODO: test encoding of structs with literals with quotes
    // TODO: test encoding of arrays into lists
    // TODO: add performance tests

    static var allTests = [
        ("test_Reading_simple_structure", test_Reading_simple_structure),
        ("test_Reading_structure_with_screened_quotes", test_Reading_structure_with_screened_quotes),
        ("test_Reading_nested_structure", test_Reading_nested_structure),
    ]
}


// TODO: move elsewhere
class StringParsingTools_spec: XCTestCase {

    func test_ClosingQuoteIndex() {

        let string = "Brb \\\"  \""

        XCTAssertNotNil(string.closingQuoteIndex())
        XCTAssertEqual(string.closingQuoteIndex(), string.index(before: string.endIndex))
    }

    func test_UnscreenedLiteral() throws {

        let literal = "Bob \\\"the Builder\\\""
        XCTAssertEqual(try literal.unscreenedLiteral(), "Bob \"the Builder\"")
    }
    
    func test_ClosingParanthesis() {
        
        let string = "brb(aou otuhf, nthue( oaeut ,24anu ())oaeu)"
        
        XCTAssertNotNil(string.closingParanthesisIndex())
        XCTAssertEqual(string.closingParanthesisIndex(), string.index(before: string.endIndex))
    }
    
    static var allTests = [
        ("test_ClosingQuoteIndex", test_ClosingQuoteIndex),
        ("test_UnscreenedLiteral", test_UnscreenedLiteral)
    ]

}
