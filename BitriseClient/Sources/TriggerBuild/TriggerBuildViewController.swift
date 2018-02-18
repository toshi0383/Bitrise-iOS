//
//  TriggerBuildViewController.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2017/12/19.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import Continuum
import TKKeyboardControl
import UIKit

class TriggerBuildViewController: UIViewController, Storyboardable, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {

    typealias Dependency = Void

    @IBOutlet private weak var baseBottomConstraint: NSLayoutConstraint!

    @IBOutlet private weak var rootStackView: UIStackView!

    @IBOutlet private weak var gitObjectInputView: GitObjectInputView! {
        didSet {
            gitObjectInputView.layer.zPosition = 1.0
        }
    }

    @IBOutlet private weak var apiTokenTextfield: UITextField!

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.allowsMultipleSelectionDuringEditing = false
        }
    }

    private weak var lastFirstResponder: UIResponder?
    private let store = LogicStore.shared
    private let bag = ContinuumBag()

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // safeArea relative margin only for iPhoneX
        if !Device.isPhoneX {
            rootStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }

        // Tell rootStackView the hitTest target.
        rootStackView.isUserInteractionEnabled = true
        rootStackView.hth.targetChildToHitTest = gitObjectInputView

        tableView.reloadData()

        apiTokenTextfield.text = store.apiToken

        let keypath: ReferenceWritableKeyPath<LogicStore, GitObject> = \.gitObject
        notificationCenter.continuum
            .observe(gitObjectInputView.newInput, bindTo: store, keypath)
            .disposed(by: bag)

        gitObjectInputView.updateUI(store.gitObject)

        // PullToDismiss
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        gesture.delegate = self
        if let grs = tableView.gestureRecognizers {
            grs.forEach {
                gesture.require(toFail: $0)
            }
        }
        view.addGestureRecognizer(gesture)

        view.keyboardTriggerOffset = 44.0;    // Input view frame height

        view.addKeyboardNonpanning(frameBasedActionHandler: { [weak self] keyboardFrameInView, firstResponder, opening, closing in
            guard let me = self else { return }

            me.lastFirstResponder = firstResponder

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

            if v.isDescendant(of: me.tableView),
                let ip = me.tableView.indexPathForSelectedRow,
                opening {
                me.tableView.deselectRow(at: ip, animated: true)
            }
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        lastFirstResponder?.resignFirstResponder()
    }

    // MARK: Handle PanGesture

    private var oldViewHeight: CGFloat = 0

    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .ended:
            print(gesture.velocity(in: view).y)
            if gesture.translation(in: view).y > view.frame.height / 2
                || gesture.velocity(in: view).y > 250.0 {
                self.dismiss(animated: true, completion: nil)
            } else {
                view.moveTo(y: 0, animated: true)
            }
        default:
            let translationY = gesture.translation(in: view).y
            if translationY > 0.5 {
                view.moveTo(y: translationY, animated: false)
            }
        }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        let location = gestureRecognizer.location(in: view)
        let viewsToIgnorePanGesture: [UIView] = [gitObjectInputView]

        for v in viewsToIgnorePanGesture {
            if v.hitTest(view.convert(location, to: v), with: nil) != nil {
                return false
            }
        }

        return true
    }

    // MARK: IBAction

    @IBAction private func triggerButton() {

        gitObjectInputView.resignFirstResponder()
        apiTokenTextfield.resignFirstResponder()

        if let text = apiTokenTextfield.text, !text.isEmpty {
            store.apiToken = text
        }

        guard let req = store.urlRequest() else {
            alert("ERROR: Could not build request.")
            return
        }

        let task = URLSession.shared.dataTask(with: req) { [weak self] (data, res, err) in

            guard let me = self else { return }

            #if DEBUG
            if let res = res as? HTTPURLResponse {
                print(res.statusCode)
                print(res.allHeaderFields)
            }
            #endif

            if let err = err {
                me.alert(err.localizedDescription)
                return
            }

            guard (res as? HTTPURLResponse)?.statusCode == 201 else {
                me.alert("Fail")
                return
            }

            let str: String = {
                if let data = data {
                    return String(data: data, encoding: .utf8) ?? ""
                } else {
                    return ""
                }
            }()

            me.alert("Success\n\(str)")
        }

        task.resume()
    }

    // MARK: UITableViewDataSource & UITableViewDelegate

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return store.workflowIDs.count
        case 1:
            return 1
        default:
            fatalError()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = store.workflowIDs[indexPath.row]
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewCell")! as! WorkflowAddNewCell
            cell.configure { [weak self] text in
                guard let me = self else { return }

                let ip = IndexPath(row: me.store.workflowIDs.count, section: 0)
                me.store.workflowIDs.append(text)
                me.tableView.insertRows(at: [ip], with: UITableViewRowAnimation.automatic)
                me.tableView.scrollToRow(at: ip, at: .top, animated: true)
            }
            return cell
        default:
            fatalError()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }

        store.workflowID = store.workflowIDs[indexPath.row]

        lastFirstResponder?.resignFirstResponder()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            store.workflowIDs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
