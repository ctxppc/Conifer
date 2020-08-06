import XCTest
@testable import Conifer

final class ConiferTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Conifer().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
