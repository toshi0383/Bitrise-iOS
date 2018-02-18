//
//  TriggerBuildViewController.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2017/12/19.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import Continuum
import UIKit

class TriggerBuildViewController: UIViewController, Storyboardable, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {

    typealias Dependency = Void

    @IBOutlet private weak var rootStackView: UIStackView!

    @IBOutlet private weak var gitObjectInputView: GitObjectInputView! {
        didSet {
            gitObjectInputView.layer.zPosition = 1.0
        }
    }

    @IBOutlet private weak var apiTokenTextfield: UITextField!
    @IBOutlet private weak var tableView: UITableView!

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
        view.addGestureRecognizer(gesture)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        gitObjectInputView.resignFirstResponder()
        apiTokenTextfield.resignFirstResponder()
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
        if let _ = gitObjectInputView.hitTest(view.convert(location, to: gitObjectInputView),
                                                with: nil) {
            return false
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
            }
            return cell
        default:
            fatalError()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        store.workflowID = store.workflowIDs[indexPath.row]
    }
}
