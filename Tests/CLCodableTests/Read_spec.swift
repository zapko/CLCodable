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
    
    
    // MARK: - Sample structures definition
    
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

    func test_Literal_tokenization_unscreens_slashes_and_quotes() throws {

        let string = "\" Brb \\\" done\""

        var tokenizer = CLTokenizer(clView: string)

        switch try tokenizer.nextToken() {
        case .some(.literal(let str)):
            XCTAssertEqual(str, " Brb \" done")

        case let wrongResult:
            XCTFail("Wrong result: \(String(describing: wrongResult))")
        }
    }

    func test_Reading_from_empty_string_throws() throws {
        
        XCTAssertThrowsError(try readStruct(clView: "") as Person) {
            error in

            switch error {
            case CLReadError.emptyView: break
            default: XCTFail("Wrong error: \(error)")
            }
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
    
    func test_Reading_many_items_is_reasonably_fast() throws {
        
        measure {
            for _ in 0...3000 { try! test_Reading_nested_structure() }
        }        
    }
    
    func test_Reading_list_creates_an_array_of_entities() throws {
        
        let people: [Person] = try readList(
            clView: """
                    (#s(person :age 7 :name "Rob") #s(person :age 8 :name "Bob"))
                    """
        )
        
        XCTAssertEqual(people.count, 2)
        XCTAssertEqual(people.first?.name, "Rob")
        XCTAssertEqual(people.first?.age, 7)
        XCTAssertEqual(people.last?.name, "Bob")
        XCTAssertEqual(people.last?.age, 8)
    }

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
