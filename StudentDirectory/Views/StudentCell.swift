import SnapKit
import UIKit

final class StudentCell: UITableViewCell {
    static let reuseIdentifier = "StudentCell"

    private enum Layout {
        static let avatarSize: CGFloat = 48
        static let avatarCornerRadius: CGFloat = 8
        static let spacing: CGFloat = 12
    }

    let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = Layout.avatarCornerRadius
        view.clipsToBounds = true
        view.isAccessibilityElement = false
        return view
    }()

    private let nameLabel = StudentCell.makeLabel(style: .headline)
    private let summaryLabel = StudentCell.makeLabel(style: .subheadline)
    private let scholarshipLabel = StudentCell.makeLabel(style: .footnote)

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, summaryLabel, scholarshipLabel])
        stack.axis = .vertical
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(textStack)
        let margins = contentView.layoutMarginsGuide
        avatarImageView.snp.makeConstraints {
            $0.leading.equalTo(margins)
            $0.top.greaterThanOrEqualTo(margins)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(Layout.avatarSize)
        }
        textStack.snp.makeConstraints {
            $0.leading.equalTo(avatarImageView.snp.trailing).offset(Layout.spacing)
            $0.trailing.equalTo(margins)
            $0.top.bottom.equalTo(margins)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    func configure(with student: Student) {
        let summary = StudentText.summary(age: student.age, grade: student.averageGrade)
        let scholarship = student.isScholarshipHolder ? StudentText.scholarship : StudentText.noScholarship
        avatarImageView.image = UIImage(named: student.avatarName) ?? UIImage(named: StudentText.defaultAvatar)
        nameLabel.text = student.name
        summaryLabel.text = summary
        scholarshipLabel.text = scholarship
        scholarshipLabel.textColor = student.isScholarshipHolder ? .systemGreen : .secondaryLabel
        isAccessibilityElement = true
        accessibilityIdentifier = AccessibilityID.studentCell(student.id)
        accessibilityLabel = "\(student.name), \(summary), \(scholarship)"
    }

    private static func makeLabel(style: UIFont.TextStyle) -> UILabel {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }
}
