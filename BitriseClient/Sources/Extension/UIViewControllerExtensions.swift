//
//  UIViewControllerExtensions.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/12.
//

import UIKit

extension UIViewController {

    func alert(_ message: String, completion: ((UIAlertAction) -> ())? = nil) {
        DispatchQueue.main.async { [weak self] in
            let vc = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
            self?.present(vc, animated: true, completion: nil)
        }
    }

    func alert(_ message: String, voidCompletion: (() -> ())?) {
        DispatchQueue.main.async { [weak self] in
            let vc = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in voidCompletion?() }))
            self?.present(vc, animated: true, completion: nil)
        }
    }

    func prompt(_ message: String, handler: (@escaping (Bool) -> ())) {
        DispatchQueue.main.async { [weak self] in
            let vc = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in handler(true) }))
            vc.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in handler(false) }))
            self?.present(vc, animated: true, completion: nil)
        }
    }
}
