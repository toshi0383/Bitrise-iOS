import RxCocoa
import UIKit

final class TextFieldDelegate: NSObject {
    let didBeginEditing = PublishRelay<String?>()
    let didEndEditing = PublishRelay<String?>()
}

extension TextFieldDelegate: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        didEndEditing.accept(textField.text)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginEditing.accept(textField.text)
    }
}

