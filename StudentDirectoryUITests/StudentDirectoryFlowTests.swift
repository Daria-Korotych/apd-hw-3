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

    func testTappingStudentOpensDetailsAndBack() {
        let app = launchApp()

        let ada = app.cells[UITestID.studentCell(Seed.adaID)]
        XCTAssertTrue(ada.waitForExistence(timeout: uiTimeout))
        ada.tap()

        XCTAssertTrue(app.otherElements[UITestID.studentDetails].waitForExistence(timeout: uiTimeout))
        XCTAssertTrue(app.staticTexts[Seed.adaName].exists)
        XCTAssertTrue(app.staticTexts[Seed.adaAgeText].exists)
        XCTAssertTrue(app.staticTexts[Seed.adaGradeText].exists)

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars[listTitle].waitForExistence(timeout: uiTimeout))
    }

    func testSubjectButtonShowsOnlyMatchingStudents() {
        let app = launchApp()

        let ada = app.cells[UITestID.studentCell(Seed.adaID)]
        XCTAssertTrue(ada.waitForExistence(timeout: uiTimeout))
        ada.tap()

        let mathButton = app.buttons[UITestID.subjectButton(Seed.mathSubject)]
        XCTAssertTrue(mathButton.waitForExistence(timeout: uiTimeout))
        mathButton.tap()

        XCTAssertTrue(app.navigationBars[Seed.mathSubject].waitForExistence(timeout: uiTimeout))
        let list = app.tables[UITestID.studentList]
        XCTAssertEqual(list.cells.count, Seed.mathNames.count)
        for name in Seed.mathNames {
            XCTAssertTrue(list.staticTexts[name].exists, "missing \(name)")
        }
        XCTAssertFalse(app.cells[UITestID.studentCell(Seed.turingID)].exists)
    }
}
