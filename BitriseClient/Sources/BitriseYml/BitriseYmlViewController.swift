import Continuum
import Highlightr
import UIKit

/// This VC is implemented without IBs.
final class BitriseYmlViewController: UIViewController {

    private let viewModel: BitriseYmlViewModel

    private let disposeBag = NotificationCenterContinuum.Bag()

    private let buttonSize: CGSize = CGSize(width: 30, height: 30)

    init(viewModel: BitriseYmlViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private let textView: UITextView = {

        let textStorage = CodeAttributedString()
        textStorage.language = "yaml"
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: .zero)
        layoutManager.addTextContainer(textContainer)

        let tv = UITextView(frame: .zero, textContainer: textContainer)
        tv.isEditable = false
        tv.tintColor = .white // cursor color
        tv.backgroundColor = textStorage.highlightr.theme.themeBackgroundColor
        tv.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
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
        v.alignment = .center
        v.spacing = 10
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.boldSystemFont(ofSize: 20)
        l.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.6)
        l.textAlignment = .center
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = (textView.textStorage as! CodeAttributedString).highlightr.theme.themeBackgroundColor

        do {
            view.addSubview(textView)

            textView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textView.topAnchor.constraint(equalTo: view.topAnchor),
                textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            ])

            notificationCenter.continuum
                .observe(viewModel.ymlPayload, on: .main, bindTo: textView, \.text)
                .disposed(by: disposeBag)
        }

        do {
            view.addSubview(buttonStackView)

            // titleLabel
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                titleLabel.widthAnchor.constraint(equalToConstant: 200),
                titleLabel.heightAnchor.constraint(equalToConstant: 20),
            ])
            titleLabel.text = viewModel.appName

            // closeButton
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                closeButton.widthAnchor.constraint(equalToConstant: buttonSize.width),
                closeButton.heightAnchor.constraint(equalToConstant: buttonSize.height),
            ])

            closeButton.addTarget(self, action: #selector(closeButtonTap), for: .touchUpInside)

            // editSaveButton
            editSaveButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                editSaveButton.widthAnchor.constraint(equalToConstant: buttonSize.width),
                editSaveButton.heightAnchor.constraint(equalToConstant: buttonSize.height),
            ])

            editSaveButton.addTarget(self, action: #selector(editSaveButtonTap), for: .touchUpInside)

            notificationCenter.continuum
                .observe(viewModel.editState, on: .main) { [weak self] in
                    guard let me = self else { return }

                    switch $0 {
                    case .editing:
                        me.hideLoading()
                        me.textView.isEditable = true
                        me.editSaveButton.setImage(me.iconSave, for: .normal)
                    case .initial:
                        me.hideLoading()
                        me.textView.isEditable = false
                        me.editSaveButton.setImage(me.iconEdit, for: .normal)
                    case .saving:
                        me.showLoading()
                        me.textView.isEditable = false
                    }

                }
                .disposed(by: disposeBag)

            // buttonStackView
            buttonStackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            ])

            buttonStackView.addArrangedSubview(titleLabel)
            buttonStackView.addArrangedSubview(editSaveButton)
            buttonStackView.addArrangedSubview(closeButton)
        }

        notificationCenter.continuum
            .observe(viewModel.alertMessage, on: .main) { [weak self] msg in
                if !msg.isEmpty {
                    self?.alert(msg)
                }
            }
            .disposed(by: disposeBag)
    }

    @objc func closeButtonTap() {
        switch viewModel.editState.value {
        case .initial:
            dismiss(animated: true, completion: nil)
        case .saving:
            dismiss(animated: true, completion: nil)
        case .editing:
            prompt("Quit editing?") { [weak self] in
                if $0 {
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
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

    private lazy var loadingView: UIView = {
        let v = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        v.translatesAutoresizingMaskIntoConstraints = false
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        base.addSubview(v)
        let parent = self.view!
        parent.addSubview(base)
        NSLayoutConstraint.activate([
            base.topAnchor.constraint(equalTo: parent.topAnchor),
            base.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            base.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            base.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            v.centerXAnchor.constraint(equalTo: base.centerXAnchor),
            v.centerYAnchor.constraint(equalTo: base.centerYAnchor),
        ])
        return base
    }()

    private func showLoading() {
        if loadingView.alpha == 1.0 {
            return
        }
        (loadingView.subviews.first as? UIActivityIndicatorView)?.startAnimating()
        UIView.animate(withDuration: 0.2) {
            self.loadingView.alpha = 1.0
        }
    }

    private func hideLoading() {
        if loadingView.alpha == 0.0 {
            return
        }
        (loadingView.subviews.first as? UIActivityIndicatorView)?.stopAnimating()
        UIView.animate(withDuration: 0.2) {
            self.loadingView.alpha = 0.0
        }
    }
}
