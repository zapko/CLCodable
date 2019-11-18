//
// Created by Zapko on 2019-11-13.
//

import XCTest
@testable import CLCodable


class NameStyling_Spec: XCTestCase {

    func test_Reading_transforms_kebab_case_to_camel_case() {

        XCTAssertEqual(
            styleFromCLToSwift(name: "SIMPLE-STRUCTURE"),
            "SimpleStructure"
        )

        XCTAssertEqual(
            styleFromCLToSwift(name: "SIMPLE-STRUCTURE", capitalizeFirst: false),
            "simpleStructure"
        )
    }

    func test_Printing_transforms_camel_case_to_kebab_case() {
        XCTAssertEqual(
            styleFromSwiftToCL(name: "SimpleStructure"),
            "SIMPLE-STRUCTURE"
        )
    }
}
