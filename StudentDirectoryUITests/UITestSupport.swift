import XCTest

let uiTimeout: TimeInterval = 15

/// Mirrors the app's AccessibilityID; the UI test target cannot import the app.
enum UITestID {
    static let studentList = "studentList"
    static let studentDetails = "studentDetails"
    static let addStudentButton = "addStudentButton"
    static let editStudentButton = "editStudentButton"
    static let studentNameField = "studentNameField"
    static let studentAgeField = "studentAgeField"
    static let saveStudentButton = "saveStudentButton"

    static func studentCell(_ id: String) -> String { "studentCell.\(id)" }
    static func subjectButton(_ subject: String) -> String { "subjectButton.\(subject)" }
}

enum Seed {
    static let studentCount = 10
    static let adaID = id(1)
    static let adaName = "Ada Lovelace"
    static let adaAgeText = "Age: 20"
    static let adaGradeText = "Average grade: 97.5"
    static let turingID = id(2)
    static let turingName = "Alan Turing"
    static let knuthName = "Donald Knuth"
    static let katherineName = "Katherine Johnson"
    static let mathSubject = "Math"
    static let mathNames = [adaName, katherineName, knuthName]

    /// Seed IDs run 00000000-0000-0000-0000-0000000000NN for NN = 01...10.
    static func id(_ number: Int) -> String {
        String(format: "00000000-0000-0000-0000-%012d", number)
    }
}

func launchApp(arguments: [String] = []) -> XCUIApplication {
    let app = XCUIApplication()
    app.launchArguments = arguments
    app.launch()
    return app
}
