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

    func test_Simple_parsing() throws {

        let data = "#S(person :age 30 :name \"Bob\")"

        struct Person {
            let name: String
            let age: Int
        }

        let person = try parse(
            data: data,
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
}
