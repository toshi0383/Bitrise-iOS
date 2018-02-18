//
//  AddNewCell.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/18.
//

import UIKit

final class WorkflowAddNewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet private(set) weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }

    private var handler: ((String) -> ())?

    func configure(_ textUpdateHandler: @escaping (String) -> ()) {
        handler = textUpdateHandler
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            handler?(text)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            textField.text = nil
            handler?(text)
        }
        return true
    }
}
