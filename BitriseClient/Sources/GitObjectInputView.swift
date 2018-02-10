//
//  GitObjectInputView.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/09.
//

import ActionPopoverButton
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

final class GitObjectInputView: UIView {

    /// Use this method to set initial value.
    func updateUI(_ gitObject: GitObject) {
        objectTextField.text = gitObject.text
        objectTypeButton.imageView.image = gitObject.image
    }

    // Input result
    // Observed by using Continuum
    var newInput: GitObject = .branch("")

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

    @IBOutlet private weak var objectTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 6

        for gitObject in GitObject.enumerated() {
            objectTypeButton.addActionButton(_button(gitObject.image)) { [weak self] in
                self?.objectTypeButton.imageView.image = gitObject.image
            }
        }
    }
}
