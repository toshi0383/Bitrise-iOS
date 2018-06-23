//
//  AnyAddNewCell.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/18.
//

import UIKit

// Add workflowID or environment
final class AnyAddNewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet private(set) weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }

    private var handler: ((String) -> ())?

    func configure(placeholder: String, _ textUpdateHandler: @escaping (String) -> ()) {
        textField.placeholder = placeholder
        handler = textUpdateHandler
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, textField.isFirstResponder {
            handler?(text)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return false
        }

        if !text.isEmpty {
            textField.text = nil
            handler?(text)
        } else {
            textField.resignFirstResponder()
        }

        return true
    }
}
