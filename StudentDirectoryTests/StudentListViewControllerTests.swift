import XCTest
@testable import StudentDirectory

final class StudentListViewControllerTests: XCTestCase {
    private let adaID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    private let mathSubject = "Math"
    private let mathStudentCount = 3
    private let renamed = "Ada King"
    private let renamedAge = 20
    private let missingAvatar = "missing-asset"
    private let cellStudentName = "Ada"
    private let cellStudentAge = 20
    private let cellStudentGrade = 90.0

    func testFilteredListReadsThroughSharedStore() throws {
        let store = StudentStore()
        let sut = StudentListViewController(store: store, subject: mathSubject)
        sut.loadViewIfNeeded()

        try store.updateStudent(id: adaID, name: renamed, age: renamedAge)

        XCTAssertEqual(sut.rows.first?.name, renamed)
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), mathStudentCount)
    }

    func testCellFallsBackToDefaultAvatar() {
        let student = Student(id: adaID, name: cellStudentName, age: cellStudentAge, averageGrade: cellStudentGrade, isScholarshipHolder: false, subjects: [], avatarName: missingAvatar)
        let cell = StudentCell(style: .default, reuseIdentifier: StudentCell.reuseIdentifier)

        cell.configure(with: student)

        XCTAssertEqual(cell.avatarImageView.image, UIImage(named: StudentText.defaultAvatar))
    }
}
