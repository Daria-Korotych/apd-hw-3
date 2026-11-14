import XCTest
@testable import StudentDirectory

final class StudentFormTests: XCTestCase {
    private let paddedAgeText = " 21 "
    private let parsedAge = 21
    private let unparsableAgeTexts = ["", "abc", "2.5"]

    func testParseAgeAcceptsTrimmedIntegersOnly() {
        XCTAssertEqual(StudentFormViewController.parseAge(paddedAgeText), parsedAge)
        for text in unparsableAgeTexts {
            XCTAssertNil(StudentFormViewController.parseAge(text), "expected nil for \(text)")
        }
        XCTAssertNil(StudentFormViewController.parseAge(nil))
    }
}
