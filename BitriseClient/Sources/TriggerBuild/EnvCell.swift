//
//  EnvCell.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/06/22.
//

import UIKit

final class EnvCell: UITableViewCell {

    @IBOutlet private(set) weak var key: UITextField!
    @IBOutlet private(set) weak var value: UITextField!
    @IBOutlet private(set) weak var enabledSwitch: UISwitch!

    @IBAction func toggle(_ anySender: AnyObject!) {
        guard let key = key.text, let value = value.text else { return }

        let newValue = BuildTriggerEnvironment(enabled: enabledSwitch.isOn,
                                               key: key,
                                               value: value)

        switchHandler?(newValue)
    }

    private var switchHandler: ((BuildTriggerEnvironment) -> ())?

    func configure(_ env: BuildTriggerEnvironment, switchHandler: @escaping (BuildTriggerEnvironment) -> ()) {
        key.text = env.key
        value.text = env.value
        enabledSwitch.isOn = env.enabled
        self.switchHandler = switchHandler
    }
}
