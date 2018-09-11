import UIKit
import SafariServices

final class TutorialViewController: UIViewController, Storyboardable, UITextFieldDelegate {

    typealias Dependency = Void

    @IBOutlet private weak var textField: UITextField! {
        didSet {
            textField.delegate = self
            textField.text = Config.shared.personalAccessToken
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Refactor with TriggerBuildVC
        view.keyboardTriggerOffset = 44.0;    // Input view frame height
        view.addKeyboardNonpanning(frameBasedActionHandler: { [weak self] keyboardFrameInView, firstResponder, opening, closing in
            guard let me = self else { return }

            guard let v = firstResponder as? UIView else { return }

            if !closing {
                let keyboardY = keyboardFrameInView.minY

                // NOTE: Set no margins between the keyboard.
                //   to avoid edge case like AddNewCell at bottom on landscape with safeArea.
                //   Modal's presentingVC(BuildListVC) would be visible in background (thru the margin space),
                //   because we are moving self.view frame on keyboard appearance.
                let vMaxY = v.convert(.zero, to: me.view).y + v.frame.height // + 4

                let delta = keyboardY - vMaxY
                if delta < 0 {
                    me.view.frame.origin.y = delta
                }
            } else {
                me.view.frame.origin.y = 0
            }
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        textField.resignFirstResponder()
    }

    // MARK: IBAction

    @IBAction func button() {
        updatePersonalAccessToken()
    }

    @IBAction func infoButton() {
        let url = URL(string: "http://devcenter.bitrise.io/api/v0.1/#authentication")!
        let sf = SFSafariViewController(url: url)
        sf.modalPresentationStyle = .overCurrentContext
        present(sf, animated: true, completion: nil)
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updatePersonalAccessToken()
        return true
    }

    // MARK: Utilities

    private func updatePersonalAccessToken() {
        guard let text = textField.text, !text.isEmpty else {
            return
        }

        Config.shared.personalAccessToken = text
        Haptic.generate(.light)
        Router.shared.showAppsList()
    }
}
