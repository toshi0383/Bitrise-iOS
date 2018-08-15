import Core
import UIKit

final class AppCell: UITableViewCell {
    func configure(_ app: MeApps.App) {
        textLabel?.text = app.title
    }
}
