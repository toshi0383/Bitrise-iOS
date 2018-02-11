//
//  BuildCell.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/11.
//

import UIKit

final class BuildCell: UITableViewCell {
    func configure(_ build: AppsBuilds.Build) {
        textLabel?.text = "#\(build.build_number) \(build.status_text)"
        
    }
}
