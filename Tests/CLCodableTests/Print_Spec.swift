//
//  Print_Spec.swift
//  CLCodableTests
//
//  Created by Zapko on 2019-11-11.
//  Copyright © 2019 Zababako. All rights reserved.
//

import XCTest
@testable import CLCodable


// FIXME: Most assertions here are fragile to implementation changes (i.e. properties reordering)

class Print_Spec: XCTestCase {
    
    
    // MARK: - Test suit
    
    func test_Printing_trivial_structure() throws {
        
        let dummy = Dummy()
        
        let clView = try clPrint(dummy)
        
        XCTAssertEqual(clView, "#S(DUMMY)")
    }
    
    func test_Printing_simple_struct() throws {
        
        let person = Person(name: "Timon", age: 4)

        let clView = try clPrint(person)

        XCTAssert(
            clView == "#S(PERSON :AGE 4 :NAME \"Timon\")" ||
            clView == "#S(PERSON :NAME \"Timon\" :AGE 4)"
        )
    }

    func test_Printing_literals_screens_quotes() throws {

        let person = Person(name: "Robert \"Bob\"", age: 55)

        let clView = try clPrint(person)

        XCTAssert(
            clView == "#S(PERSON :AGE 55 :NAME \"Robert \\\"Bob\\\"\")" ||
            clView == "#S(PERSON :NAME \"Robert \\\"Bob\\\"\" :AGE 55)"
        )
    }

    func test_Printing_nested_struct() throws {

        let couple = Couple(
            one: .init(name: "Fox",  age: 30),
            two: .init(name: "Dana", age: 29)
        )

        let clView = try clPrint(couple)

        XCTAssert(
            clView == "#S(COUPLE :ONE #S(PERSON :NAME \"Fox\" :AGE 30) :TWO #S(PERSON :NAME \"Dana\" :AGE 29))" ||
            clView == "#S(COUPLE :ONE #S(PERSON :NAME \"Fox\" :AGE 30) :TWO #S(PERSON :AGE 29 :NAME \"Dana\"))" ||
            clView == "#S(COUPLE :ONE #S(PERSON :AGE 30 :NAME \"Fox\") :TWO #S(PERSON :NAME \"Dana\" :AGE 29))" ||
            clView == "#S(COUPLE :ONE #S(PERSON :AGE 30 :NAME \"Fox\") :TWO #S(PERSON :AGE 29 :NAME \"Dana\"))" ||
            clView == "#S(COUPLE :TWO #S(PERSON :NAME \"Dana\" :AGE 29) :ONE #S(PERSON :NAME \"Fox\" :AGE 30))" ||
            clView == "#S(COUPLE :TWO #S(PERSON :AGE 29 :NAME \"Dana\") :ONE #S(PERSON :NAME \"Fox\" :AGE 30))" ||
            clView == "#S(COUPLE :TWO #S(PERSON :NAME \"Dana\" :AGE 29) :ONE #S(PERSON :AGE 30 :NAME \"Fox\"))" ||
            clView == "#S(COUPLE :TWO #S(PERSON :AGE 29 :NAME \"Dana\") :ONE #S(PERSON :AGE 30 :NAME \"Fox\"))",
            "Not matching '\(clView)'"
        )
    }

    func test_Printing_lists() throws {

        let list = [
            Person(name: "Timon", age: 4),
            Person(name: "Pumba", age: 5),
        ]

        let clView = try clPrint(list)

        XCTAssert(
            clView == "(#S(PERSON :AGE 4 :NAME \"Timon\") #S(PERSON :AGE 5 :NAME \"Pumba\"))" ||
            clView == "(#S(PERSON :AGE 4 :NAME \"Timon\") #S(PERSON :NAME \"Pumba\" :AGE 5))" ||
            clView == "(#S(PERSON :NAME \"Timon\" :AGE 4) #S(PERSON :AGE 5 :NAME \"Pumba\"))" ||
            clView == "(#S(PERSON :NAME \"Timon\" :AGE 4) #S(PERSON :NAME \"Pumba\" :AGE 5))",
            "Not matching '\(clView)'"
        )
    }

    func test_Printing_many_items_is_reasonably_fast() throws {
        
        measure {
            do {
                for _ in 0...10000 { try test_Printing_nested_struct() }
            } catch {
                XCTFail("Failed to run single iteration")
            }
        }
    }
}
