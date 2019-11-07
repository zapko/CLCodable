//
//  Parser_spec.swift
//  cl-codableTests
//
//  Created by Zapko on 2019-11-03.
//  Copyright © 2019 Zababako. All rights reserved.
//

import XCTest
@testable import CLCodable

class Parser_spec: XCTestCase {

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

    func test_Simple_parsing() throws {

        let person: Person = try read(
            clView: "#s(person :age 30 :name \"Bob\")"
        )

        XCTAssertEqual(person.name, "Bob")
        XCTAssertEqual(person.age, 30)
    }

    func test_Parsing_screened_quotes() throws {

        let person: Person = try read(
            clView: "#s(person :age 30 :name \"Bob \\\"the Builder\\\"\")"
        )

        XCTAssertEqual(person.name, "Bob \"the Builder\"")
        XCTAssertEqual(person.age, 30)
    }

    // TODO: test nested structures parsing
    // TODO: test transformation from kebab to camel cases for property names
    // TODO: test upper cased format of CL structures
    // TODO: test lists transformation into arrays
    // TODO: add performance tests
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
}
