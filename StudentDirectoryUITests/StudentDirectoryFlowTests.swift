import XCTest

final class StudentDirectoryFlowTests: XCTestCase {
    private let listTitle = "Students"
    private let accessibilityTextSizeArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]

    override func setUp() {
        continueAfterFailure = false
    }

    func testListShowsAllStudentsWithTitle() {
        let app = launchApp()

        XCTAssertTrue(app.navigationBars[listTitle].waitForExistence(timeout: uiTimeout))
        XCTAssertTrue(app.tables[UITestID.studentList].waitForExistence(timeout: uiTimeout))
        for number in 1...Seed.studentCount {
            let cell = app.cells[UITestID.studentCell(Seed.id(number))]
            XCTAssertTrue(cell.exists, "missing cell for seed student \(number)")
        }
    }

    func testListUsableAtAccessibilityTextSize() {
        let app = launchApp(arguments: accessibilityTextSizeArguments)

        let ada = app.cells[UITestID.studentCell(Seed.adaID)]
        XCTAssertTrue(ada.waitForExistence(timeout: uiTimeout))
        XCTAssertTrue(ada.isHittable)
    }
}
