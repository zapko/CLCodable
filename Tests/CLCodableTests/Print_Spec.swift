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
        
        let clView = try printStruct(dummy)
        
        XCTAssertEqual(clView, "#S(DUMMY)")
    }
    
    func test_Printing_simple_struct() throws {
        
        let person = Person(name: "Timon", age: 4)

        let clView = try printStruct(person)

        XCTAssert(
            clView == "#S(PERSON :AGE 4 :NAME \"Timon\")" ||
            clView == "#S(PERSON :NAME \"Timon\" :AGE 4)"
        )
    }

    func test_Printing_literals_screens_quotes() throws {

        let person = Person(name: "Robert \"Bob\"", age: 55)

        let clView = try printStruct(person)

        XCTAssertEqual(clView, "#S(PERSON :NAME \"Robert \\\"Bob\\\"\" :AGE 55)")
    }

    func test_Printing_nested_struct() throws {

        let couple = Couple(
            one: .init(name: "Fox",  age: 30),
            two: .init(name: "Dana", age: 29)
        )

        let clView = try printStruct(couple)

        XCTAssertEqual(clView, "#S(COUPLE :ONE #S(PERSON :NAME \"Fox\" :AGE 30) :TWO #S(PERSON :NAME \"Dana\" :AGE 29))")
    }

    func test_Printing_lists() throws {
        XCTFail("Not implemented")
    }

    func test_Printing_many_items_is_reasonably_fast() throws {
        XCTFail("Not implemented")
    }
}
