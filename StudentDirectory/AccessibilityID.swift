import Foundation

enum AccessibilityID {
    static let studentList = "studentList"
    static let studentDetails = "studentDetails"
    static let addStudentButton = "addStudentButton"
    static let editStudentButton = "editStudentButton"
    static let studentNameField = "studentNameField"
    static let studentAgeField = "studentAgeField"
    static let saveStudentButton = "saveStudentButton"

    static func studentCell(_ id: UUID) -> String { "studentCell.\(id.uuidString)" }
    static func subjectButton(_ subject: String) -> String { "subjectButton.\(subject)" }
}

enum StudentText {
    static let scholarship = "Scholarship"
    static let noScholarship = "No scholarship"
    static let defaultAvatar = "avatar-default"

    static func summary(age: Int, grade: Double) -> String {
        "Age \(age) · Grade \(String(format: "%.1f", grade))"
    }
}
