import SnapKit
import UIKit

extension StudentStoreError {
    var message: String {
        switch self {
        case .blankName: "Name can't be blank"
        case .nonPositiveAge: "Age must be greater than 0"
        case .unknownID: "This student no longer exists"
        }
    }
}

final class StudentFormViewController: UIViewController {
    enum Mode {
        case add
        case edit(UUID)
    }

    private enum Layout {
        static let spacing: CGFloat = 12
        static let inset: CGFloat = 16
    }

    static let invalidAgeMessage = "Age must be a whole number"
    static let cancelTitle = "Cancel"
    static let saveTitle = "Save"
    private static let addTitle = "New Student"
    private static let editTitle = "Edit Student"
    private static let namePlaceholder = "Name"
    private static let agePlaceholder = "Age"
    private static let alertTitle = "Can't save"
    private static let alertDismissTitle = "OK"

    private let store: StudentStore
    private let mode: Mode
    private let onSave: () -> Void

    let nameField = StudentFormViewController.makeField(
        placeholder: namePlaceholder, identifier: AccessibilityID.studentNameField, keyboard: .default)
    let ageField = StudentFormViewController.makeField(
        placeholder: agePlaceholder, identifier: AccessibilityID.studentAgeField, keyboard: .numberPad)

    init(store: StudentStore, mode: Mode, onSave: @escaping () -> Void) {
        self.store = store
        self.mode = mode
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    static func parseAge(_ text: String?) -> Int? {
        Int((text ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        switch mode {
        case .add: title = Self.addTitle
        case .edit: title = Self.editTitle
        }
        view.backgroundColor = .systemGroupedBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: Self.cancelTitle, style: .plain, target: self, action: #selector(cancelTapped))
        let save = UIBarButtonItem(title: Self.saveTitle, style: .done, target: self, action: #selector(saveTapped))
        save.accessibilityIdentifier = AccessibilityID.saveStudentButton
        navigationItem.rightBarButtonItem = save

        let stack = UIStackView(arrangedSubviews: [nameField, ageField])
        stack.axis = .vertical
        stack.spacing = Layout.spacing
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Layout.inset)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Layout.inset)
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        guard let age = Self.parseAge(ageField.text) else {
            showAlert(message: Self.invalidAgeMessage)
            return
        }
        do {
            switch mode {
            case .add: try store.addStudent(name: nameField.text ?? "", age: age)
            case .edit(let id): try store.updateStudent(id: id, name: nameField.text ?? "", age: age)
            }
        } catch let error as StudentStoreError {
            showAlert(message: error.message)
            return
        } catch {
            showAlert(message: error.localizedDescription)
            return
        }
        dismiss(animated: true) { [onSave] in onSave() }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: Self.alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Self.alertDismissTitle, style: .default))
        present(alert, animated: true)
    }

    private static func makeField(placeholder: String, identifier: String, keyboard: UIKeyboardType) -> UITextField {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.placeholder = placeholder
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
        field.keyboardType = keyboard
        field.accessibilityIdentifier = identifier
        return field
    }
}
