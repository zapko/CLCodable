//
//  Print_Spec.swift
//  CLCodableTests
//
//  Created by Zapko on 2019-11-11.
//  Copyright © 2019 Zababako. All rights reserved.
//

import XCTest
@testable import CLCodable


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

    // TODO: test encoding of nested structs
    // TODO: test encoding of structs with literals with quotes
    // TODO: test encoding of arrays into lists
    // TODO: add performance tests



}
