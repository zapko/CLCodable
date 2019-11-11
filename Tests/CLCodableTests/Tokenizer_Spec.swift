//
//  Tokenizer_Spec.swift
//  CLCodable
//
//  Created by Zapko on 2019-11-11.
//

import XCTest
@testable import CLCodable


class Tokenizer_Spec: XCTestCase {

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

}
