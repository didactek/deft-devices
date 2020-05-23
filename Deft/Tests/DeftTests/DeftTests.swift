import XCTest
@testable import Deft

final class DeftTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Deft().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
