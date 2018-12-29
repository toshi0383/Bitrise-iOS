import UIKit

extension UITextField {

    /// Programmatically update text field to fire event via delegate or Rx.UIControlProperty
    func updateText(_ text: String) {
        self.text = ""
        insertText(text)
    }
}
