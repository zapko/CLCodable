import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(StringParsingTools_spec.allTests),
        testCase(Read_spec.allTests)
    ]
}
#endif
