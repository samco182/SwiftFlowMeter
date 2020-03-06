import XCTest
@testable import SwiftFlowMeter

final class SwiftFlowMeterTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftFlowMeter().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
