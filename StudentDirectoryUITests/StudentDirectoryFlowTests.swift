import XCTest

final class StudentDirectoryFlowTests: XCTestCase {
    private let listTitle = "Students"
    private let newName = "Grace Hopper"
    private let newAge = "35"
    private let cancelTitle = "Cancel"
    private let editedName = "Ada Byron"
    private let editedAge = "41"
    private let extraText = " Jr"
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

    func testAddStudentAppendsRow() {
        let app = launchApp()

        let add = app.buttons[UITestID.addStudentButton]
        XCTAssertTrue(add.waitForExistence(timeout: uiTimeout))
        add.tap()
        let nameField = app.textFields[UITestID.studentNameField]
        XCTAssertTrue(nameField.waitForExistence(timeout: uiTimeout))
        nameField.tap()
        nameField.typeText(newName)
        let ageField = app.textFields[UITestID.studentAgeField]
        ageField.tap()
        ageField.typeText(newAge)
        app.buttons[UITestID.saveStudentButton].tap()

        let list = app.tables[UITestID.studentList]
        XCTAssertTrue(list.staticTexts[newName].waitForExistence(timeout: uiTimeout))
        XCTAssertEqual(list.cells.count, Seed.studentCount + 1)
    }

    func testAddBlankNameShowsAlertAndKeepsList() {
        let app = launchApp()

        let add = app.buttons[UITestID.addStudentButton]
        XCTAssertTrue(add.waitForExistence(timeout: uiTimeout))
        add.tap()
        let ageField = app.textFields[UITestID.studentAgeField]
        XCTAssertTrue(ageField.waitForExistence(timeout: uiTimeout))
        ageField.tap()
        ageField.typeText(newAge)
        app.buttons[UITestID.saveStudentButton].tap()

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: uiTimeout))
        alert.buttons.firstMatch.tap()
        app.navigationBars.buttons[cancelTitle].tap()

        let list = app.tables[UITestID.studentList]
        XCTAssertTrue(list.waitForExistence(timeout: uiTimeout))
        XCTAssertEqual(list.cells.count, Seed.studentCount)
    }

    func testEditStudentUpdatesDetailsAndList() {
        let app = launchApp()
        openEditForm(in: app)

        let nameField = app.textFields[UITestID.studentNameField]
        replaceText(in: nameField, with: editedName)
        let ageField = app.textFields[UITestID.studentAgeField]
        replaceText(in: ageField, with: editedAge)
        app.buttons[UITestID.saveStudentButton].tap()

        XCTAssertTrue(app.staticTexts[DetailTextForTests.age(editedAge)].waitForExistence(timeout: uiTimeout))
        XCTAssertTrue(app.staticTexts[editedName].exists)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        let list = app.tables[UITestID.studentList]
        XCTAssertTrue(list.staticTexts[editedName].waitForExistence(timeout: uiTimeout))
        XCTAssertFalse(list.staticTexts[Seed.adaName].exists)
    }

    func testCancelEditKeepsStudent() {
        let app = launchApp()
        openEditForm(in: app)

        let nameField = app.textFields[UITestID.studentNameField]
        nameField.tap()
        nameField.typeText(extraText)
        app.navigationBars.buttons[cancelTitle].tap()

        XCTAssertTrue(app.otherElements[UITestID.studentDetails].waitForExistence(timeout: uiTimeout))
        XCTAssertTrue(app.staticTexts[Seed.adaName].exists)
    }

    private func openEditForm(in app: XCUIApplication) {
        let ada = app.cells[UITestID.studentCell(Seed.adaID)]
        XCTAssertTrue(ada.waitForExistence(timeout: uiTimeout))
        ada.tap()
        let edit = app.buttons[UITestID.editStudentButton]
        XCTAssertTrue(edit.waitForExistence(timeout: uiTimeout))
        edit.tap()
        XCTAssertTrue(app.textFields[UITestID.studentNameField].waitForExistence(timeout: uiTimeout))
    }

    private func replaceText(in field: XCUIElement, with text: String) {
        field.tap()
        let current = field.value as? String ?? ""
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count))
        field.typeText(text)
    }
}

private enum DetailTextForTests {
    static func age(_ age: String) -> String { "Age: \(age)" }
}
