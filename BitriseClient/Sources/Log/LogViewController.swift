import Core
import Highlightr
import RxCocoa
import RxSwift
import UIKit

final class LogViewController: UIViewController {

    private let build: AppsBuilds.Build

    init(build: AppsBuilds.Build) {
        self.build = build
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private let textView: UITextView = {

        let textStorage = CodeAttributedString()
        textStorage.language = "console"
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: .zero)
        layoutManager.addTextContainer(textContainer)

        let tv = UITextView(frame: .zero, textContainer: textContainer)
        tv.isEditable = false
        tv.tintColor = .white // cursor color
        tv.backgroundColor = textStorage.highlightr.theme.themeBackgroundColor
        tv.contentInset = .zero
        return tv
    }()
}

// MARK: Lifecycle

extension LogViewController {

    override func viewDidLoad() {

        super.viewDidLoad()

        navigationItem.title = "#\(build.build_number)"

        view.backgroundColor = (textView.textStorage as! CodeAttributedString).highlightr.theme.themeBackgroundColor

        do {
            view.addSubview(textView)

            textView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textView.topAnchor.constraint(equalTo: view.topAnchor),
                textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                ])

            if let data = BuildLogDownloader.shared.data(forBuildSlug: build.slug),
                let text = String(data: data, encoding: .utf8) {

                textView.text = text
            }
        }

    }
}
