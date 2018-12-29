import UIKit

// MARK: UIView

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

}

// MARK: UITraitCollection

extension UITraitCollection {
    var isPortrait: Bool {
        return verticalSizeClass != .compact
    }
}

// MARK: UIStackView

extension UIStackView {

    convenience init(axis: NSLayoutConstraint.Axis,
                     spacing: CGFloat,
                     alignment: Alignment,
                     distribution: Distribution,
                     arrangedSubviews: [UIView] = []) {
        self.init(arrangedSubviews: arrangedSubviews)

        self.distribution = distribution
        self.axis = axis
        self.spacing = spacing
        self.alignment = alignment
    }

}
