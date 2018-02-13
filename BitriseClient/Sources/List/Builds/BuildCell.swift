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

private struct BuildDescription {
    let text: String
    init(build: AppsBuilds.Build) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
        self.text = "#\(build.build_number) \(build.status_text)\ntriggeredAt: \(formatter.string(from: build.triggered_at))"
    }
}

final class BuildCell: UITableViewCell {
    func configure(_ build: AppsBuilds.Build) {
        textLabel?.text = BuildDescription(build: build).text
        textLabel?.numberOfLines = 0
        detailTextLabel?.text = PullRequestDescription(build: build).text
        accessoryType = build.status == .notFinished ? .detailButton : .none
    }
}
