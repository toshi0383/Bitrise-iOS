import APIKit
import Core
import DifferenceKit
import Highlightr
import RxCocoa
import RxSwift
import UIKit

final class LogViewController: UIViewController {

    private let build: AppsBuilds.Build

    init(appSlug: AppSlug, build: AppsBuilds.Build, session: Session = .shared) {
        self.build = build

        super.init(nibName: nil, bundle: nil)

        if build.status == .notFinished {
            var previous: [AppsBuildsLog.Chunk] = []

            Observable<Int>.interval(.seconds(2), scheduler: ConcurrentMainScheduler.instance)
                .startWith(0)
                .flatMapFirst { _ -> Observable<AppsBuildsLog> in
                    let req = AppsBuildsLogRequest(appSlug: appSlug, buildSlug: build.slug)

                    return session.rx.send(req)
                        .timeout(.seconds(10), scheduler: ConcurrentMainScheduler.instance)
                }
                .distinctUntilChanged()
                .takeUntil(.exclusive, predicate: { $0.expiring_raw_log_url != nil })
                .map { $0.log_chunks.sorted(by: { (f, s) in f.position < s.position }) }
                .map { chunks -> [AppsBuildsLog.Chunk] in
                    chunks.count > 9 ? [AppsBuildsLog.Chunk](chunks[0...9]) : chunks
                }
                .flatMapFirst { next -> Observable<[AppsBuildsLog.Chunk]> in
                    let c = StagedChangeset(source: previous, target: next)

                    guard let result = c.last else {
                        return .empty()
                    }

                    previous = next

                    return .just(result.elementInserted.map { result.data[$0.element] })
                }
                .map { $0.map { c in c.chunk }.joined(separator: "\n") }
                .observeOn(ConcurrentMainScheduler.instance)
                .subscribe(onNext: { [weak self] log in
                    guard let me = self else { return }

                    me.textView.text.append(log)
                })
                .disposed(by: rx.disposeBag)
        }
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
