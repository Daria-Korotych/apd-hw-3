import XCTest
@testable import StudentDirectory

final class StudentStoreTests: XCTestCase {
    private let adaID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    private let unknownID = UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")!
    private let seedCount = 10
    private let algorithms = "Algorithms"
    private let expectedAlgorithmsNames = ["Ada Lovelace", "Alan Turing", "Grace Hopper", "Edsger Dijkstra", "Donald Knuth"]
    private let lowercaseMath = "math"
    private let math = "Math"
    private let mathCount = 3
    private let defaultAvatar = "avatar-default"
    private let validName = "Linus Torvalds"
    private let validAge = 19
    private let defaultAverageGrade = 0.0
    private let whitespaceOnlyName = "  \n"
    private let invalidAges = [0, -1]
    private let updatedName = "Ada King"
    private let updatedAge = 36

    func testMatchingSubjectReturnsExactMatchesInStoreOrder() {
        let store = StudentStore()
        XCTAssertEqual(store.students(matchingSubject: algorithms).map(\.name), expectedAlgorithmsNames)
    }

    func testMatchingSubjectIsCaseSensitive() {
        let store = StudentStore()
        XCTAssertTrue(store.students(matchingSubject: lowercaseMath).isEmpty)
        XCTAssertEqual(store.students(matchingSubject: math).count, mathCount)
    }

    func testAddStudentAppendsDefaults() throws {
        let store = StudentStore()
        try store.addStudent(name: validName, age: validAge)

        XCTAssertEqual(store.students.count, seedCount + 1)
        let added = try XCTUnwrap(store.students.last)
        XCTAssertEqual(added.name, validName)
        XCTAssertEqual(added.age, validAge)
        XCTAssertEqual(added.averageGrade, defaultAverageGrade)
        XCTAssertFalse(added.isScholarshipHolder)
        XCTAssertTrue(added.subjects.isEmpty)
        XCTAssertEqual(added.avatarName, defaultAvatar)
        XCTAssertFalse(StudentSeedData.students.map(\.id).contains(added.id))
    }

    func testAddStudentRejectsInvalidInputWithoutMutation() {
        let store = StudentStore()
        for blank in ["", whitespaceOnlyName] {
            XCTAssertThrowsError(try store.addStudent(name: blank, age: validAge)) {
                XCTAssertEqual($0 as? StudentStoreError, .blankName)
            }
        }
        for age in invalidAges {
            XCTAssertThrowsError(try store.addStudent(name: validName, age: age)) {
                XCTAssertEqual($0 as? StudentStoreError, .nonPositiveAge)
            }
        }
        XCTAssertEqual(store.students, StudentSeedData.students)
    }

    func testUpdateStudentChangesOnlyNameAndAge() throws {
        let store = StudentStore()
        try store.updateStudent(id: adaID, name: updatedName, age: updatedAge)

        let ada = try XCTUnwrap(store.students.first { $0.id == adaID })
        let seedAda = try XCTUnwrap(StudentSeedData.students.first { $0.id == adaID })
        XCTAssertEqual(ada.name, updatedName)
        XCTAssertEqual(ada.age, updatedAge)
        XCTAssertEqual(ada.averageGrade, seedAda.averageGrade)
        XCTAssertEqual(ada.isScholarshipHolder, seedAda.isScholarshipHolder)
        XCTAssertEqual(ada.subjects, seedAda.subjects)
        XCTAssertEqual(ada.avatarName, seedAda.avatarName)
        XCTAssertEqual(store.students.filter { $0.id != adaID }, StudentSeedData.students.filter { $0.id != adaID })

        let before = store.students
        XCTAssertThrowsError(try store.updateStudent(id: unknownID, name: updatedName, age: updatedAge)) {
            XCTAssertEqual($0 as? StudentStoreError, .unknownID(unknownID))
        }
        XCTAssertEqual(store.students, before)
    }

    func testDeleteStudentRemovesOnlyThatStudent() throws {
        let store = StudentStore()
        try store.deleteStudent(id: adaID)
        XCTAssertEqual(store.students.count, seedCount - 1)
        XCTAssertFalse(store.students.contains { $0.id == adaID })

        XCTAssertThrowsError(try store.deleteStudent(id: unknownID)) {
            XCTAssertEqual($0 as? StudentStoreError, .unknownID(unknownID))
        }
        XCTAssertEqual(store.students.count, seedCount - 1)
    }
}
