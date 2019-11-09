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
    
    struct Person: CLDecodable {
        let name: String
        let age:  Int

        init(from slots: [String : CLToken]) throws {

            guard let name = try slots["name"]?.string() else {
                throw CLReadError.missingValue(.init("name"))
            }

            self.name = name

            guard let age = try slots["age"]?.int() else {
                throw CLReadError.missingValue(.init("age"))
            }

            self.age = age
        }
    }
    
    struct Couple: CLDecodable  {
        let one: Person
        let two: Person
        
        init(from slots: [String : CLToken]) throws {

            guard let one: Person = try slots["one"]?.clStruct() else {
                throw CLReadError.missingValue(.init("one"))
            }

            self.one = one

            guard let two: Person = try slots["two"]?.clStruct() else {
                throw CLReadError.missingValue(.init("two"))
            }

            self.two = two
        }
    }

    
    // MARK: - Test suit

    func test_Literal_tokenization() throws {

        let string = "\" Brb \\\" done\""

        var tokenizer = Tokenizer(clView: string)

        switch try tokenizer.nextToken() {
        case .some(.literal(let str)):
            XCTAssertEqual(str, " Brb \" done")

        case let wrongResult:
            XCTFail("Wrong result: \(String(describing: wrongResult))")
        }
    }

    func test_Reading_simple_structure() throws {

        let person: Person = try readStruct(
            clView: "#s(person :age 30 :name \"Bob\")"
        )

        XCTAssertEqual(person.name, "Bob")
        XCTAssertEqual(person.age, 30)
    }

    func test_Reading_structure_with_screened_quotes() throws {

        let person: Person = try readStruct(
            clView: "#s(person :age 30 :name \"Bob \\\"the Builder\\\"\")"
        )

        XCTAssertEqual(person.name, "Bob \"the Builder\"")
        XCTAssertEqual(person.age, 30)
    }
    
    func test_Reading_nested_structure() throws {
    
        let couple: Couple = try readStruct(
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
    
    func test_Parsing_performance() throws {
        
        measure {
            for _ in 0...3000 { try! test_Reading_nested_structure() }
        }        
    }

    // TODO: test lists transformation into arrays
    // TODO: test transformation from kebab to camel cases for property names
    // TODO: test upper cased format of CL structures

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
