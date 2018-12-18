import ActionPopoverButton
import RxSwift
import RxCocoa
import UIKit

private extension GitObject {
    var image: UIImage {
        switch self {
        case .branch:
            return UIImage(named: "git-branch")!
        case .tag:
            return UIImage(named: "git-tag")!
        case .commitHash:
            return UIImage(named: "git-commit")!
        }
    }

    var text: String {
        switch self {
        case .branch(let v): return v
        case .tag(let v): return v
        case .commitHash(let v): return v
        }
    }
}

private final class GitObjectTypeButton: ActionPopoverButton {

    let imageView: UIImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {
        addSubview(imageView)
    }

    override func updateConstraints() {
        super.updateConstraints()

        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        backgroundColor = UIColor.gitRed
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        backgroundColor = UIColor.gitRedHighlight
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        backgroundColor = UIColor.gitRed
    }
}

private func _button(_ image: UIImage) -> UIButton {
    let b = UIButton(type: .system)
    b.setImage(image, for: .normal)
    b.layer.cornerRadius = 6
    b.tintColor = .white
    b.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        b.heightAnchor.constraint(equalToConstant: 40),
        b.widthAnchor.constraint(equalToConstant: 40),
    ])
    return b
}

final class GitObjectInputView: UIView, UITextFieldDelegate {

    struct Placeholder {
        let text: String

        init(_ gitObject: GitObject) {
            switch gitObject {
            case .branch:
                self.text = "branch"
            case .tag:
                self.text = "tag"
            case .commitHash:
                self.text = "commit"
            }
        }
    }

    // Input result
    let newInput: Observable<GitObject>
    private let _newInput = BehaviorRelay<GitObject>(value: .branch(""))

    var getSuggestionForType: ((String) -> [String])? {
        didSet {
            // set once
            assert(oldValue == nil)
        }
    }

    private let objectTypeButton: GitObjectTypeButton = {
        let button = GitObjectTypeButton()
        button.backgroundColor = UIColor.baseGreen
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 0.3
        button.layer.borderColor = UIColor(hex: 0x888888).cgColor
        button.tintColor = .white
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalTo: button.heightAnchor)
        ])
        return button
    }()

    @IBOutlet private weak var stackView: UIStackView! {
        didSet {
            stackView.insertArrangedSubview(objectTypeButton, at: 0)
        }
    }

    @IBOutlet private weak var objectTextField: UITextField! {
        didSet {
            objectTextField.delegate = self
        }
    }

    override init(frame: CGRect) {
        self.newInput = _newInput.changed
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        self.newInput = _newInput.changed
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 6

        for gitObject in GitObject.enumerated() {
            objectTypeButton.addActionButton(_button(gitObject.image)) { [weak self] in
                guard let me = self else { return }

                me.objectTypeButton.imageView.image = gitObject.image

                me._newInput.accept(gitObject.updateAssociatedValue(me.objectTextField.text ?? ""))
                me.updatePlaceholder()

                Haptic.generate(.heavy)
            }
        }

        objectTypeButton.onFocusActionChanged {
            Haptic.generate(.light)
        }
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        objectTextField.resignFirstResponder()

        return super.resignFirstResponder()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hit = super.hitTest(point, with: event) {
            return hit
        }

        return objectTypeButton.hitTest(convert(point, to: objectTypeButton), with: event)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let f = getSuggestionForType {
            let suggestion: [String] = f(_newInput.value.type)
            print(suggestion)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let str = objectTextField.text ?? ""
        _newInput.accept(_newInput.value.updateAssociatedValue(str))
        updatePlaceholder()
    }

    // MARK: Utilities

    /// Use this method to set initial value.
    func updateUI(_ gitObject: GitObject) {
        objectTextField.text = gitObject.text
        objectTextField.placeholder = Placeholder(gitObject).text
        objectTypeButton.imageView.image = gitObject.image
    }

    private func updatePlaceholder() {
        objectTextField.placeholder = Placeholder(_newInput.value).text
    }
}
