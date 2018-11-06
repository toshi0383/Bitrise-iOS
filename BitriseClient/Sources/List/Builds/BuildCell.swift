import Core
import RxSwift
import UIKit

final class BuildCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var branchLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel2: UILabel!

    @IBOutlet private weak var smallSquareView: UIView! {
        didSet {
            smallSquareView.layer.cornerRadius = 6
        }
    }

    private weak var timer: Timer?

    private let formatter = DateFormatter()

    private(set) var reuseDisposeBag = DisposeBag()
}

// MARK: Lifecycle

extension BuildCell {

    override func prepareForReuse() {
        super.prepareForReuse()

        _prepareForReuse()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        _prepareForReuse()
    }

}

// MARK: Utility

extension BuildCell {

    private func _prepareForReuse() {
        reuseDisposeBag = DisposeBag()

        timer?.invalidate()

        accessoryType = .detailButton

        titleLabel.text = nil
        branchLabel.text = nil
        subtitleLabel.text = nil
        subtitleLabel2.text = nil
    }

    func configure(_ build: AppsBuilds.Build) {
        titleLabel.text = "#\(build.build_number) \(build.status_text) [\(build.triggered_workflow)]"

        do {
            var text = ""
            if let target = build.pull_request_target_branch {
                if let branch = build.branch {
                    text = "\(target) <= \(branch)"
                } else {
                    assertionFailure("For PRs build.branch should exist, or not?")
                }
            }
            else if let tagOrbranch = (build.tag ?? build.branch) {
                text = "\(tagOrbranch)"
            }
            branchLabel.text = text
        }

        if let color = StatusColor(rawValue: build.status_text) {
            smallSquareView.backgroundColor = color.value
        } else {
            smallSquareView.backgroundColor = .clear
        }

        let triggeredTimeString = formatter.string(from: build.triggered_at, type: .hourMinuteSecond1)
        subtitleLabel.text = "Triggered @ \(triggeredTimeString)"

        timer?.invalidate()

        if build.status == .notFinished {
            if let started_at = build.environment_prepare_finished_at {
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                    guard timer.isValid else { return }
                    guard let me = self else { return }

                    let timeInterval = Int(Date().timeIntervalSince(started_at))
                    let minutes = Int(timeInterval / 60)
                    let seconds = timeInterval % (max(minutes, 1) * 60)
                    me.subtitleLabel2.text = "\(minutes)m \(seconds)s"
                }
            } else {
                subtitleLabel2.text = "preparing"
            }
        } else {
            if let finished_at = build.finished_at,
                let started_at = build.environment_prepare_finished_at {

                let timeInterval = max(0, Int(finished_at.timeIntervalSince(started_at)))
                let minutes = Int(timeInterval / 60)
                let seconds = timeInterval % (max(minutes, 1) * 60)
                subtitleLabel2.isHidden = timeInterval == 0
                subtitleLabel2.text = "\(minutes)m \(seconds)s"
            } else {
                subtitleLabel2.text = "n/a"

                // happens when aborted before it starts.
                // assertionFailure("finished_at should exist")
            }
        }
    }
}

// MARK: Inner Types

extension BuildCell {

    private enum StatusColor: String {
        case inProgress = "in-progress"
        case success = "success"
        case aborted = "aborted"
        case error = "error"
        case onHold = "on-hold"

        var value: UIColor {
            switch self {
            case .inProgress:
                return .buildInProgress
            case .success:
                return .buildSuccess
            case .aborted:
                return .buildAborted
            case .error:
                return .buildError
            case .onHold:
                return .buildOnHold
            }
        }
    }

    private struct DateFormatter {

        enum `Type` {
            case hourMinuteSecond1
            case minuteSecond1
        }

        private let formatter = Foundation.DateFormatter()

        func string(from date: Date, type: Type) -> String {
            switch type {
            case .hourMinuteSecond1:
                formatter.dateFormat = "HH:mm:ss"
                return formatter.string(from: date)
            case .minuteSecond1:
                formatter.dateFormat = "mm'm' ss's'"
                return formatter.string(from: date)
            }
        }
    }

}
