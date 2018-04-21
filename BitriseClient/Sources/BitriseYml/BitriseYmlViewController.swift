import Continuum
import UIKit

/// This VC is implemented without IBs.
final class BitriseYmlViewController: UIViewController {

    private let viewModel: BitriseYmlViewModel

    private let disposeBag = NotificationCenterContinuum.Bag()

    init(viewModel: BitriseYmlViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        let font = UIFont.systemFont(ofSize: 22)
        tv.font = font
        return tv
    }()

    private let iconEdit = UIImage(named: "icn-edit")!.withRenderingMode(.alwaysTemplate)
    private let iconSave = UIImage(named: "icn-save")!.withRenderingMode(.alwaysTemplate)

    private let closeButton: UIButton = {
        let b = UIButton(type: .custom)
        let img = UIImage(named: "icn-close")!.withRenderingMode(.alwaysTemplate)
        b.setImage(img, for: .normal)
        b.tintColor = .gray
        b.backgroundColor = .clear
        b.layer.cornerRadius = 10
        return b
    }()

    private lazy var editSaveButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(self.iconEdit, for: .normal)
        b.tintColor = .gray
        b.backgroundColor = .clear
        b.layer.cornerRadius = 10
        return b
    }()

    private let buttonStackView: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.distribution = .equalSpacing
        v.spacing = 10
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        do {
            view.addSubview(textView)

            textView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textView.topAnchor.constraint(equalTo: view.topAnchor),
                textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                textView.widthAnchor.constraint(equalToConstant: 1080),
            ])

            notificationCenter.continuum
                .observe(viewModel.ymlPayload, on: .main, bindTo: textView, \.text)
                .disposed(by: disposeBag)
        }

        do {
            view.addSubview(buttonStackView)

            // closeButton
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                closeButton.widthAnchor.constraint(equalToConstant: 50),
                closeButton.heightAnchor.constraint(equalToConstant: 50),
            ])

            closeButton.addTarget(self, action: #selector(closeButtonTap), for: .touchUpInside)

            // editSaveButton
            editSaveButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                editSaveButton.widthAnchor.constraint(equalToConstant: 50),
                editSaveButton.heightAnchor.constraint(equalToConstant: 50),
            ])

            editSaveButton.addTarget(self, action: #selector(editSaveButtonTap), for: .touchUpInside)

            notificationCenter.continuum
                .observe(viewModel.editState, on: .main) { [weak self] in
                    guard let me = self else { return }

                    let img: UIImage
                    switch $0 {
                    case .editing:
                        img = me.iconSave
                        me.textView.isEditable = true
                    default:
                        img = me.iconEdit
                        me.textView.isEditable = false // TODO
                    }

                    me.editSaveButton.setImage(img, for: .normal)
                }
                .disposed(by: disposeBag)

            // buttonStackView
            buttonStackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            ])

            buttonStackView.addArrangedSubview(editSaveButton)
            buttonStackView.addArrangedSubview(closeButton)
        }
    }

    @objc func closeButtonTap() {
        dismiss(animated: true, completion: nil)
    }

    @objc func editSaveButtonTap() {
        if viewModel.editState.value == .editing {
            prompt("Upload bitrise.yml?") { [weak self] in
                if $0 {
                    self?.viewModel.editSaveButtonTap()
                }
            }
        } else {
            viewModel.editSaveButtonTap()
        }
    }
}
