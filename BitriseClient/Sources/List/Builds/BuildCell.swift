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
        d = "\(d) [\(build.triggered_workflow)]"
        self.text = d
    }
}

final class BuildCell: UITableViewCell {
    func configure(_ build: AppsBuilds.Build) {
        textLabel?.text = "#\(build.build_number) \(build.status_text)\n\(PullRequestDescription(build: build).text)"
        textLabel?.numberOfLines = 0

        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
        detailTextLabel?.text = "triggeredAt: \(formatter.string(from: build.triggered_at))"

        accessoryType = build.status == .notFinished ? .detailButton : .none
    }
}
