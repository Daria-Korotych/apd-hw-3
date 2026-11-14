import SnapKit
import UIKit

final class StudentDetailViewController: UIViewController {
    private enum Layout {
        static let avatarSize: CGFloat = 96
        static let avatarCornerRadius: CGFloat = 16
        static let spacing: CGFloat = 12
        static let horizontalInset: CGFloat = 16
    }

    private let store: StudentStore
    private let studentID: UUID

    private let scrollView = UIScrollView()

    private let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = Layout.avatarCornerRadius
        view.clipsToBounds = true
        view.isAccessibilityElement = false
        return view
    }()

    private let nameLabel = StudentDetailViewController.makeLabel(style: .title1)
    private let ageLabel = StudentDetailViewController.makeLabel(style: .body)
    private let gradeLabel = StudentDetailViewController.makeLabel(style: .body)
    private let scholarshipLabel = StudentDetailViewController.makeLabel(style: .body)
    private let idLabel = StudentDetailViewController.makeLabel(style: .body)
    private let avatarLabel = StudentDetailViewController.makeLabel(style: .body)
    private let subjectsHeaderLabel = StudentDetailViewController.makeLabel(style: .headline)

    private let subjectsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = Layout.spacing
        return stack
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            avatarImageView, nameLabel, ageLabel, gradeLabel, scholarshipLabel,
            idLabel, avatarLabel, subjectsHeaderLabel, subjectsStack,
        ])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = Layout.spacing
        return stack
    }()

    init(store: StudentStore, studentID: UUID) {
        self.store = store
        self.studentID = studentID
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.accessibilityIdentifier = AccessibilityID.studentDetails
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentStack.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide).inset(Layout.horizontalInset)
            $0.width.equalTo(scrollView.frameLayoutGuide).offset(-2 * Layout.horizontalInset)
        }
        avatarImageView.snp.makeConstraints { $0.size.equalTo(Layout.avatarSize) }
        subjectsHeaderLabel.text = DetailText.subjectsHeader
        subjectsHeaderLabel.accessibilityTraits = .header
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    func reload() {
        guard let student = store.students.first(where: { $0.id == studentID }) else {
            if navigationController?.topViewController === self {
                navigationController?.popViewController(animated: false)
            }
            return
        }
        title = student.name
        avatarImageView.image = UIImage(named: student.avatarName) ?? UIImage(named: StudentText.defaultAvatar)
        nameLabel.text = student.name
        ageLabel.text = DetailText.age(student.age)
        gradeLabel.text = DetailText.grade(student.averageGrade)
        scholarshipLabel.text = DetailText.scholarship(student.isScholarshipHolder)
        idLabel.text = DetailText.id(student.id)
        avatarLabel.text = DetailText.avatar(student.avatarName)
        rebuildSubjects(student.subjects)
    }

    private func rebuildSubjects(_ subjects: [String]) {
        subjectsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for subject in subjects {
            var configuration = UIButton.Configuration.tinted()
            configuration.title = subject
            configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
                var attributes = attributes
                attributes.font = .preferredFont(forTextStyle: .body)
                return attributes
            }
            let button = UIButton(configuration: configuration, primaryAction: UIAction { [weak self] _ in
                self?.showStudents(matching: subject)
            })
            button.accessibilityIdentifier = AccessibilityID.subjectButton(subject)
            subjectsStack.addArrangedSubview(button)
        }
    }

    private func showStudents(matching subject: String) {
        let list = StudentListViewController(store: store, subject: subject)
        navigationController?.pushViewController(list, animated: true)
    }

    private static func makeLabel(style: UIFont.TextStyle) -> UILabel {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }
}
