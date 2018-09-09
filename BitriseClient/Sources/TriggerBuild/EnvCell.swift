import UIKit

final class EnvCell: UITableViewCell {

    @IBOutlet private(set) weak var key: UITextField!
    @IBOutlet private(set) weak var value: UITextField!
    @IBOutlet private(set) weak var enabledSwitch: UISwitch!
    
    private lazy var textFieldDelegate: TextFieldDelegate = {
        return TextFieldDelegate { [weak self] _ in
            // NOTE: retaining delegate instance by implicit strong self capture
            self?.toggle(nil)
        }
    }()

    private var pkey = ""

    @IBAction func toggle(_ anySender: AnyObject!) {
        guard let key = key.text, let value = value.text else { return }

        let newValue = BuildTriggerEnvironment(pkey: pkey,
                                               enabled: enabledSwitch.isOn,
                                               key: key,
                                               value: value)

        switchHandler?(newValue)
    }

    private var switchHandler: ((BuildTriggerEnvironment) -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()

        key.delegate = textFieldDelegate
        value.delegate = textFieldDelegate
    }

    func configure(_ env: BuildTriggerEnvironment, switchHandler: @escaping (BuildTriggerEnvironment) -> ()) {
        pkey = env.pkey
        key.text = env.key
        value.text = env.value
        enabledSwitch.isOn = env.enabled
        self.switchHandler = switchHandler
    }
}
