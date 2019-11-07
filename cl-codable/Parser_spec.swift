//
//  Parser_spec.swift
//  cl-codableTests
//
//  Created by Zapko on 2019-11-03.
//  Copyright © 2019 Zababako. All rights reserved.
//

import XCTest
@testable import cl_codable

class Parser_spec: XCTestCase {

    struct Person {
        let name: String
        let age: Int
    }

    func test_Simple_parsing() throws {

        let person = try read(
            clStruct: "#s(person :age 30 :name \"Bob\")",
            catalog: [
                "person" : {
                    Person(name: $0["name"]!, age: Int($0["age"]!)!)
                }
            ]
        ) as? Person

        XCTAssertNotNil(person)
        XCTAssertEqual(person?.name, "Bob")
        XCTAssertEqual(person?.age, 30)
    }

    func test_Parsing_screened_quotes() throws {

        let person = try read(
            clStruct: "#s(person :age 30 :name \"Bob \\\"Builder\\\"\")",
            catalog: [
                "person" : {
                    Person(name: $0["name"]!, age: Int($0["age"]!)!)
                }
            ]
        ) as? Person

        XCTAssertNotNil(person)
        XCTAssertEqual(person?.name, "Bob \"Builder\"")
        XCTAssertEqual(person?.age, 30)
    }

    // TODO: test nested structures parsing
    // TODO: test transformation from kebab to camel cases
    // TODO: test upper cased format of CL structures
    // TODO: test lists transformation into arrays
}


// TODO: move elsewhere
class StringParsingTools_spec: XCTestCase {

    func test_ClosingQuoteIndex() {

        let string = "Brb \\\"  \""

        XCTAssertNotNil(string.closingQuoteIndex())
        XCTAssertEqual(string.closingQuoteIndex(), string.index(before: string.endIndex))
    }

    func test_UnscreenedLiteral() throws {

        let literal = "Bob \\\"Builder\\\""
        XCTAssertEqual(try literal.unscreenedLiteral(), "Bob \"Builder\"")
    }
}
