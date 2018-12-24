import UIKit

final class SuggestionTableView: UITableView {

    private var suggestions: [String] = []

    func reloadSuggestions(_ suggestions: [String]) {
        self.suggestions = suggestions
        heightConstraint.constant = CGFloat(min(suggestions.count, 3) * 44)
        reloadData()
    }

    private var heightConstraint: NSLayoutConstraint!
    private let reuseID = UUID().uuidString
    private let suggestionHandler: (String) -> ()

    init(suggestions: [String], suggestionHandler: @escaping (String) -> ()) {
        self.suggestions = suggestions
        self.suggestionHandler = suggestionHandler

        super.init(frame: .zero, style: .plain)

        delegate = self
        dataSource = self

        translatesAutoresizingMaskIntoConstraints = false

        register(UITableViewCell.self, forCellReuseIdentifier: reuseID)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}

// MARK: Lifecycle

extension SuggestionTableView {
    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
    }
}

// MARK: TableView

extension SuggestionTableView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        cell.textLabel?.text = suggestions[indexPath.row]
        return cell
    }
}

extension SuggestionTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.row < suggestions.count else {
            fatalError()
        }

        suggestionHandler(suggestions[indexPath.row])
    }
}
