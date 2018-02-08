//
//  ViewController.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2017/12/19.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let workflowIDs: [WorkflowID] = WorkflowID.elements

    @IBOutlet private weak var gitObjectTextfield: UITextField!
    @IBOutlet private weak var apiTokenTextfield: UITextField!

    @IBOutlet private weak var tableView: UITableView!

    private let store: LogicStore = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        apiTokenTextfield.text = store.apiToken
    }

    // MARK: Alert

    private func alert(_ message: String) {
        DispatchQueue.main.async {
            let vc = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(vc, animated: true, completion: nil)
        }
    }

    // MARK: IBAction

    @IBAction private func triggerButton() {

        gitObjectTextfield.resignFirstResponder()
        apiTokenTextfield.resignFirstResponder()

        if let text = apiTokenTextfield.text, !text.isEmpty {
            store.apiToken = text
        }

        store.setGitObject(text: gitObjectTextfield.text)

        guard let req = store.urlRequest() else {
            alert("ERROR: リクエストを生成できませんでした.")
            return
        }

        let task = URLSession.shared.dataTask(with: req) { [weak self] (data, res, err) in

            guard let me = self else { return }
            if let res = res as? HTTPURLResponse {
                print(res.statusCode)
                print(res.allHeaderFields)
            }

            if let err = err {
                me.alert(err.localizedDescription)
                return
            }

            guard (res as? HTTPURLResponse)?.statusCode == 201 else {
                me.alert("失敗")
                return
            }

            let str: String = {
                if let data = data {
                    return String(data: data, encoding: .utf8) ?? ""
                } else {
                    return ""
                }
            }()

            me.alert("成功\n\(str)")
        }

        task.resume()
    }

    // MARK: UITableViewDataSource & UITableViewDelegate

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workflowIDs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = workflowIDs[indexPath.row].rawValue
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        store.workflowID = workflowIDs[indexPath.row]
    }

}
