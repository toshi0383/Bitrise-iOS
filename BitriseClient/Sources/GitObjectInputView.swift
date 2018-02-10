//
//  GitObjectInputView.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/09.
//

import UIKit

final class GitObjectInputView: UIView {
    @IBOutlet private weak var objectTypeButton: UIButton! {
        didSet {
            objectTypeButton.layer.cornerRadius = 6
            objectTypeButton.layer.borderWidth = 0.3
            objectTypeButton.layer.borderColor = UIColor(hex: 0x888888).cgColor
            objectTypeButton.tintColor = .white
        }
    }

    @IBOutlet private weak var objectTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 6
    }

    @IBAction private func button() {
//        PopoverAction.shared.showPopover(from: self)
//        UIPopoverPresentationController
    }
}
