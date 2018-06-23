//
//  EnvCell.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/06/22.
//

import UIKit

final class EnvCell: UITableViewCell {

    @IBOutlet private(set) weak var label: UILabel!

    @IBAction func toggle(_ sender: UISwitch!) {
        switchHandler?(sender.isOn)
    }

    private var switchHandler: ((Bool) -> ())?

    func configure(text: String, switchHandler: @escaping (Bool) -> ()) {
        label.text = text
        self.switchHandler = switchHandler
    }
}
