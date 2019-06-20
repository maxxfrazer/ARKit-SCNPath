import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ARKit_SCNPathTests.allTests),
    ]
}
#endif
