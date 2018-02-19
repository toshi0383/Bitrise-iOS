//
//  AppCell.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/11.
//

import UIKit

final class AppCell: UITableViewCell {
    func configure(_ app: MeApps.App) {
        textLabel?.text = app.title
    }
}
