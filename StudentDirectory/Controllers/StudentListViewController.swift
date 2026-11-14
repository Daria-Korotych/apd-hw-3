import SnapKit
import UIKit

final class StudentListViewController: UIViewController {
    private static let defaultTitle = "Students"

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
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
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
}
