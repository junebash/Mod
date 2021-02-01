import XCTest
@testable import Mod

final class ModTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Mod().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
