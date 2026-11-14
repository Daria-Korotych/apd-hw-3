import SnapKit
import UIKit

final class StudentListViewController: UIViewController {
    private static let defaultTitle = "Students"
    private static let addStudentLabel = "Add student"
    private static let deleteActionTitle = "Delete"

    private let store: StudentStore
    private let subject: String?

    let tableView: UITableView = {
        let table = UITableView()
        table.accessibilityIdentifier = AccessibilityID.studentList
        table.rowHeight = UITableView.automaticDimension
        table.register(StudentCell.self, forCellReuseIdentifier: StudentCell.reuseIdentifier)
        return table
    }()

    var rows: [Student] {
        subject.map { store.students(matchingSubject: $0) } ?? store.students
    }

    init(store: StudentStore, subject: String? = nil) {
        self.store = store
        self.subject = subject
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = subject ?? Self.defaultTitle
        if subject == nil {
            let add = UIBarButtonItem(systemItem: .add, primaryAction: UIAction { [weak self] _ in self?.presentAddForm() })
            add.accessibilityIdentifier = AccessibilityID.addStudentButton
            add.accessibilityLabel = Self.addStudentLabel
            navigationItem.rightBarButtonItem = add
        }
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func presentAddForm() {
        let form = StudentFormViewController(store: store, mode: .add) { [weak self] in
            self?.tableView.reloadData()
        }
        present(UINavigationController(rootViewController: form), animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

extension StudentListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StudentCell.reuseIdentifier, for: indexPath)
        (cell as? StudentCell)?.configure(with: rows[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let details = StudentDetailViewController(store: store, studentID: rows[indexPath.row].id)
        navigationController?.pushViewController(details, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let id = rows[indexPath.row].id
        let delete = UIContextualAction(style: .destructive, title: Self.deleteActionTitle) { [weak self] _, _, completion in
            guard let self else { return completion(false) }
            do {
                try store.deleteStudent(id: id)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completion(true)
            } catch {
                tableView.reloadData()
                completion(false)
            }
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
