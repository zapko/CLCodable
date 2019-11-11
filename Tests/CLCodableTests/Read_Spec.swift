//
//  Read_Spec.swift
//  CLCodableTests
//
//  Created by Zapko on 2019-11-03.
//  Copyright © 2019 Zababako. All rights reserved.
//

import XCTest
@testable import CLCodable


class Read_Spec: XCTestCase {

    
    // MARK: - Test suit

    func test_Reading_from_empty_string_throws() throws {
        
        XCTAssertThrowsError(try readStruct(clView: "") as Dummy) {
            error in

            switch error {
            case CLReadError.emptyView: break
            default: XCTFail("Wrong error: \(error)")
            }
        }
    }

    func test_Reading_unnamed_struct_throws() throws {

        XCTAssertThrowsError(try readStruct(clView: "#s()") as Dummy) {
            error in

            switch error {
            case CLReadError.dataCorrupted: break
            default: XCTFail("Wrong error: \(error)")
            }
        }
    }

    func test_Reading_anything_except_struct__list_or_atom_throws() throws {

        let errorExpectation: (Error) -> Void = {
            error in

            switch error {
            case CLReadError.dataCorrupted: break
            default: XCTFail("Wrong error: \(error)")
            }
        }

        XCTAssertThrowsError(try readStruct(clView: "#j(dummy)")  as Dummy) { errorExpectation($0) }
        XCTAssertThrowsError(try readStruct(clView: "?(dummy)")   as Dummy) { errorExpectation($0) }
        XCTAssertThrowsError(try readStruct(clView: "#sk(dummy)") as Dummy) { errorExpectation($0) }
    }

    func test_Reading_trivial_structure() {
        XCTAssertNoThrow(try readStruct(clView: "#s(dummy)") as Dummy)
    }

    func test_Reading_simple_structure() throws {

        let person: Person = try readStruct(
            clView: "#s(person :age 30 :name \"Bob\")"
        )

        XCTAssertEqual(person.name, "Bob")
        XCTAssertEqual(person.age, 30)
    }

    func test_Reading_simple_structure_ignores_additional_spaces_and_newlines() throws {

        let person: Person = try readStruct(
            clView: """
                    #s(  person    :age   30 
                    :name 
                    \"Bob\")
                    """
        )

        XCTAssertEqual(person.name, "Bob")
        XCTAssertEqual(person.age, 30)
    }

    func test_Reading_simple_structure_with_duplicate_values_throws() {

        let data = "#s(person :age 30 :name \"Bob\" :age 23)"

        XCTAssertThrowsError(try readStruct(clView: data) as Person) {
            error in

            switch error {
            case CLReadError.dataCorrupted: break
            default: XCTFail("Wrong error: \(error)")
            }
        }
    }

    func test_Reading_simple_structure_with_unclear_field_names_throws() {

        let data = "#s(person :age 30 name \"Bob\")"

        XCTAssertThrowsError(try readStruct(clView: data) as Person) {
            error in

            switch error {
            case CLReadError.dataCorrupted: break
            default: XCTFail("Wrong error: \(error)")
            }
        }
    }

    func test_Reading_structure_with_screened_quotes_unscreens_them_in_value() throws {

        let person: Person = try readStruct(
            clView: "#s(person :age 30 :name \"Bob \\\"the Builder\\\"\")"
        )

        XCTAssertEqual(person.name, "Bob \"the Builder\"")
        XCTAssertEqual(person.age, 30)
    }

    func test_Reading_simple_structure_with_malformed_number_throws() {

        let data = "#s(person :age 3p0 name \"Bob\")"

        XCTAssertThrowsError(try readStruct(clView: data) as Person) {
            error in

            switch error {
            case CLReadError.dataCorrupted: break
            default: XCTFail("Wrong error: \(error)")
            }
        }
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
                    (#s(person :age 30 :name "Rob") 
                     #s(person :age 27 :name "Bob")
                     #s(person :age 33 :name "Cop"))
                    """
        )
        
        XCTAssertEqual(people.count, 3)
        XCTAssertEqual(people.first?.name, "Rob")
        XCTAssertEqual(people.first?.age, 30)
        XCTAssertEqual(people.last?.name, "Cop")
        XCTAssertEqual(people.last?.age, 33)
    }

    // TODO: test transformation from kebab to camel cases for property names
    // TODO: test upper cased format of CL structures

    static var allTests = [
        ("test_Reading_simple_structure", test_Reading_simple_structure),
        ("test_Reading_nested_structure", test_Reading_nested_structure)
    ]
}
