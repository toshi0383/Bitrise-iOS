import RxCocoa
import RxSwift
import UIKit

// MARK: EnvCell

final class EnvCell: UITableViewCell {

    private let colon: UILabel = {
        let l = UILabel(frame: .zero)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 17)

        let c = l.widthAnchor.constraint(equalToConstant: 4.6)

        c.priority = .required
        c.isActive = true

        return l
    }()

    private let enabledSwitch: UISwitch
    private let key: UITextField
    private let value: UITextField

    private var trailingMargin: NSLayoutConstraint!
    private var pkey = ""
    private var reuseDisposeBag = DisposeBag()

    init(style: UITableViewCell.CellStyle,
         reuseIdentifier: String?,
         key: UITextField = _textField("KEY"),
         value: UITextField = _textField("VALUE"),
         enabledSwitch: UISwitch) {

        self.enabledSwitch = enabledSwitch
        self.key = key
        self.value = value

        super.init(style: .default, reuseIdentifier: "EnvCell")

        backgroundColor = .clear

        let rootStackView = UIStackView(
            axis: .horizontal,
            spacing: 10,
            alignment: .center,
            distribution: .fill,
            arrangedSubviews: [
                enabledSwitch,
                UIStackView(
                    axis: .horizontal,
                    spacing: 0,
                    alignment: .fill,
                    distribution: .fill,
                    arrangedSubviews: [
                        key, colon, value
                    ]
                )
            ]
        )

        NSLayoutConstraint.activate([
            key.widthAnchor.constraint(equalTo: value.widthAnchor),
        ])

        contentView.addSubview(rootStackView)

        rootStackView.translatesAutoresizingMaskIntoConstraints = false

        trailingMargin = rootStackView.trailingAnchor
            .constraint(equalTo: contentView.trailingAnchor,
                        constant: trailingMargin(forTraitCollection: traitCollection))

        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            rootStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            trailingMargin,
        ])
    }

    convenience override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.init(style: style, reuseIdentifier: reuseIdentifier, enabledSwitch: _enabledSwitch())
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}

// MARK: Lifecycle

extension EnvCell {

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        trailingMargin.constant = trailingMargin(forTraitCollection: traitCollection)
    }

}

// MARK: Utilities

extension EnvCell {

    private func trailingMargin(forTraitCollection t: UITraitCollection) -> CGFloat {
        return t.isPortrait ? -10 : -44
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        reuseDisposeBag = DisposeBag()
    }

    func configure(_ env: BuildTriggerEnvironment, switchHandler: @escaping (BuildTriggerEnvironment) -> ()) {

        pkey = env.pkey
        key.text = env.key
        value.text = env.value
        enabledSwitch.isOn = env.enabled

        Observable
            .combineLatest(enabledSwitch.rx.value,
                           key.rx.text.asObservable(),
                           value.rx.text.asObservable())
            .subscribe(onNext: { [weak self] (enabled, key, value) in
                guard let key = key,
                    let value = value,
                    let me = self,
                    !me.pkey.isEmpty else { return }

                let newValue = BuildTriggerEnvironment(pkey: me.pkey,
                                                       enabled: enabled,
                                                       key: key,
                                                       value: value)

                switchHandler(newValue)
            })
            .disposed(by: reuseDisposeBag)
    }

}

// MARK: Factory

private func _textField(_ placeholder: String) -> UITextField {
    let tf = UITextField(frame: .zero)
    tf.translatesAutoresizingMaskIntoConstraints = false
    tf.autocapitalizationType = .none
    tf.backgroundColor = .white
    tf.spellCheckingType = .no
    tf.returnKeyType = .default
    tf.borderStyle = .roundedRect
    tf.adjustsFontSizeToFitWidth = true
    tf.font = UIFont.systemFont(ofSize: 14)
    return tf
}


private func _enabledSwitch() -> UISwitch {

    let s = UISwitch(frame: .zero)

    s.translatesAutoresizingMaskIntoConstraints = false
    s.onTintColor = UIColor(hex: 0x4B9CBF)
    s.isEnabled = true

    return s
}
