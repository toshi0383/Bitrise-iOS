import UIKit

final class TextFieldDelegate: NSObject, UITextFieldDelegate {

    typealias Handler = (String) -> ()

    private let handler: Handler

    init(_ handler: @escaping Handler) {
        self.handler = handler
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, textField.isFirstResponder {
            handler(text)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return false
        }

        if !text.isEmpty {
            handler(text)
        }

        return true
    }
}

