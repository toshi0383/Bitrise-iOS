//
//  BuildCell.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/11.
//

import UIKit

final class BuildCell: UITableViewCell {

    enum StatusColor: String {
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

    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = nil
        }
    }

    @IBOutlet private weak var branchLabel: UILabel! {
        didSet {
            branchLabel.text = nil
        }
    }

    @IBOutlet private weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.text = nil
        }
    }

    @IBOutlet private weak var subtitleLabel2: UILabel! {
        didSet {
            subtitleLabel2.text = nil
        }
    }

    @IBOutlet private weak var smallSquareView: UIView! {
        didSet {
            smallSquareView.layer.cornerRadius = 6
        }
    }

    private weak var timer: Timer?

    struct DateFormatter {

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

    let formatter = DateFormatter()

    override func prepareForReuse() {
        super.prepareForReuse()

        timer?.invalidate()

        titleLabel.text = nil
        branchLabel.text = nil
        subtitleLabel.text = nil
        subtitleLabel2.text = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        accessoryType = .detailButton
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

        if build.status == .notFinished {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard timer.isValid else { return }
                guard let me = self else { return }

                if let started_at = build.environment_prepare_finished_at {
                    let timeInterval = Int(Date().timeIntervalSince(started_at))
                    let minutes = Int(timeInterval / 60)
                    let seconds = timeInterval % (max(minutes, 1) * 60)
                    me.subtitleLabel2.text = "\(minutes)m \(seconds)s"
                } else {
                    me.subtitleLabel2.text = "preparing"
                }
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
