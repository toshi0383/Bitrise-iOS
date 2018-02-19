//
//  BuildCell.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/11.
//

import UIKit

private struct PullRequestDescription {
    let text: String
    init(build: AppsBuilds.Build) {
        var d = ""
        if let target = build.pull_request_target_branch {
            d = "\(target) <="
        }
        if let branch = build.branch {
            d = "\(d) \(branch)"
        }
        d = "\(d)"
        self.text = d
    }
}

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

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var branchLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    @IBOutlet private weak var smallSquareView: UIView! {
        didSet {
            smallSquareView.layer.cornerRadius = 6
        }
    }

    func configure(_ build: AppsBuilds.Build) {
        titleLabel.text = "#\(build.build_number) \(build.status_text) [\(build.triggered_workflow)]"
        branchLabel.text = PullRequestDescription(build: build).text

        if let color = StatusColor(rawValue: build.status_text) {
            smallSquareView.backgroundColor = color.value
        } else {
            smallSquareView.backgroundColor = .clear
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
        subtitleLabel.text = "triggeredAt: \(formatter.string(from: build.triggered_at))"

        accessoryType = build.status == .notFinished ? .detailButton : .none
    }
}
