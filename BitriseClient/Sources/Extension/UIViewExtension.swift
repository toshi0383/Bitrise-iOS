//
//  UIViewExtension.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/12.
//

import UIKit

extension UIView {
    func moveTo(y: CGFloat, animated: Bool, completion: ((Bool) -> ())? = nil) {
        let r = CGRect(origin: CGPoint(x: frame.origin.x, y: y),
                       size: frame.size)
        let work: () -> () = {
            self.frame = r
        }
        if animated {
            UIView.animate(withDuration: 0.5, animations: work, completion: completion)
        } else {
            work()
        }
    }

    func changeHeight(to: CGFloat) {
        let r = CGRect(origin: frame.origin,
                       size: CGSize(width: frame.width, height: to))
        self.frame = r
    }
}
