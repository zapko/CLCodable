import XCTest
@testable import CLCodable

final class CLCodableTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CLCodable().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
