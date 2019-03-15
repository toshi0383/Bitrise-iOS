import Foundation
import RxCocoa
import RxSwift

final class BuildLogDownloader {

    private let destDir = URL(fileURLWithPath: NSHomeDirectory().appending("/Library/Caches/LogFiles/"))
    private let fm: FileManager = .default
    private var downloadTasks: [String: DownloadProgress] = [:]
    private var removeTasks: [String: RemoveProgress] = [:]
    private let fileRemoveScheduler = SerialDispatchQueueScheduler(qos: .background)
    private let _newDownloadProgress = PublishRelay<DownloadProgress>()
    private let _newRemoveProgress = PublishRelay<RemoveProgress>()

    static let shared = BuildLogDownloader()

    private init() { }

}

// MARK: API

extension BuildLogDownloader {

    func isDownloaded(_ buildSlug: String) -> Bool {
        return fm.fileExists(atPath: fileURL(forBuildSlug: buildSlug).path)
    }

    func downloadProgress(forBuildSlug slug: String) -> Observable<DownloadProgress> {
        var observables: [Observable<DownloadProgress>] = []

        if let progress = downloadTasks.first(where: { (_, progress) in progress.buildSlug == slug })?.value {
            observables.append(Observable.just(progress))
        } else {
            observables.append(_newDownloadProgress.filter { $0.buildSlug == slug })
        }

        if isDownloaded(slug) {
            observables.append(Observable.just(DownloadProgress.completed(slug)))
        }

        return Observable.merge(observables)
    }

    func removeProgress(forBuildSlug slug: String) -> Observable<RemoveProgress> {
        if let progress = removeTasks.first(where: { (_, progress) in progress.buildSlug == slug })?.value {
            return .just(progress)
        } else {
            return _newRemoveProgress.filter { $0.buildSlug == slug }
        }
    }

    @discardableResult
    func enqueue(url: String, buildSlug: String) -> DownloadProgress {
        print("start download for url: \(url), buildSlug: \(buildSlug)")

        let destFileURL = self.fileURL(forBuildSlug: buildSlug)

        let progress = DownloadProgress(url: url,
                                        buildSlug: buildSlug,
                                        destFileURL: destFileURL)
        downloadTasks[url] = progress
        _newDownloadProgress.accept(progress)

        let configuration = URLSessionConfiguration
            .background(withIdentifier:
                "jp.toshi0383.Bitrise-iOS.BuildLogDownloader.\(buildSlug)")

        configuration.allowsCellularAccess = false

        let session = URLSession(configuration: configuration,
                                 delegate: progress,
                                 delegateQueue: OperationQueue())

        let task = session.downloadTask(with: URL(string: url)!)

        progress.task = task

        progress.state.asObservable()
            .subscribe(onNext: { [unowned self] state in

                if case .completed = state {
                    self.cleanDownloadTaskIfExists(buildSlug: buildSlug)
                }
            })
            .disposed(by: progress.rx.disposeBag)

        // Invalidate session once finished.
        // So same session Identifier can be reused.
        session.finishTasksAndInvalidate()

        task.resume()

        return progress
    }

    /// Reads whole data from disk if exists.
    /// Could be expensive process.
    func data(forBuildSlug string: String) -> Data? {
        let url = fileURL(forBuildSlug: string)

        if !isRemoving(string) && fm.fileExists(atPath: url.path) {
            return fm.contents(atPath: url.path)
        }

        return nil
    }

    @discardableResult
    func removeData(forBuildSlug buildSlug: String) -> RemoveProgress? {
        if !fm.fileExists(atPath: fileURL(forBuildSlug: buildSlug).path) {
            return nil
        }

        let progress = RemoveProgress(buildSlug: buildSlug)

        removeTasks[buildSlug] = progress
        _newRemoveProgress.accept(progress)

        cleanDownloadTaskIfExists(buildSlug: buildSlug)

        progress._completed
            .subscribe(onNext: { [unowned self] in
                self.removeTasks[buildSlug] = nil
            })
            .disposed(by: progress.disposeBag)

        startRemove(progress)

        return progress
    }
}

// MARK: Utilities

extension BuildLogDownloader {

    /// Reads whole data from disk if exists.
    /// Could be expensive process.
    func wholeText(forBuildSlug string: String) -> String? {

        if let data = data(forBuildSlug: string) {
            return String(data: data, encoding: .utf8)!
        }

        return nil

    }

    private func cleanDownloadTaskIfExists(buildSlug: String) {
        for (url, progress) in downloadTasks {
            if progress.buildSlug == buildSlug {
                downloadTasks[url]?.task?.cancel()
                downloadTasks[url] = nil
            }
        }
    }

    private func startRemove(_ progress: RemoveProgress) {
        let fm = self.fm
        let filePath = fileURL(forBuildSlug: progress.buildSlug).path

        Observable
            .create { o in
                do {
                    try fm.removeItem(atPath: filePath)
                    o.onNext(())
                    o.onCompleted()
                } catch {
                    o.onError(error)
                }
                return Disposables.create()
            }
            .subscribeOn(fileRemoveScheduler)
            .bind(to: progress._completed)
            .disposed(by: progress.disposeBag)
    }

    private func isRemoving(_ url: String) -> Bool {
        return removeTasks[url] != nil
    }

    private func fileURL(forBuildSlug buildSlug: String) -> URL {
        return destDir.appendingPathComponent("\(buildSlug).log")
    }

}

extension BuildLogDownloader {

    final class DownloadProgress: NSObject {
        let buildSlug: String

        private let url: String
        private let destFileURL: URL
        fileprivate var task: URLSessionDownloadTask?
        private let fm: FileManager

        fileprivate let _progress = BehaviorRelay<Double?>(value: nil)
        fileprivate let _completed = BehaviorRelay<Void?>(value: nil)

        private let disposeBag = DisposeBag()

        init(url: String,
             buildSlug: String,
             destFileURL: URL,
             fm: FileManager = .default) {
            self.url = url
            self.buildSlug = buildSlug
            self.destFileURL = destFileURL
            self.fm = fm
        }

        static func completed(_ buildSlug: String) -> DownloadProgress {
            let p = DownloadProgress(url: "",
                                     buildSlug: buildSlug,
                                     destFileURL: URL(string: "http://")!)
            p._completed.accept(())
            return p
        }

        var state: Property<State> {
            let completed: Observable<State> = _completed.asObservable()
                .filterNil()
                .map { State.completed }
                .share()

            return Property(unsafeObservable:
                Observable.merge(
                    Observable.just(.initial)
                        .concat(completed).debug("[state-0]"),
                    _progress.asObservable()
                        .filterNil()
                        .map { State.inProgress($0) }
                        .takeUntil(completed).debug("[state-1]")
                )
            )
        }

        enum State {
            case initial
            case inProgress(Double)
            case completed
        }
    }

    final class RemoveProgress {
        fileprivate let buildSlug: String
        fileprivate let disposeBag = DisposeBag()

        /// May emit error.
        fileprivate let _completed = PublishSubject<Void>()

        let completed: Observable<Void>

        init(buildSlug: String) {
            self.buildSlug = buildSlug
            self.completed = _completed.catchError { _ in .empty() }
        }
    }

}

extension BuildLogDownloader.DownloadProgress: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {

        print("[didFinishDownloadingTo] location: \(location), downloadTask.state: \(downloadTask.state)")

        // File move must be done here, not in the down stream of _completed.
        // By that time, the file at `location` is deleted. (seems too fast to me..)
        // It didn't matter if you subscribe without scheduler, which should be called synchronously.
        do {
            mkdirIfNeeded(destFileURL.deletingLastPathComponent())
            try fm.moveItem(at: location, to: destFileURL)
        } catch {
            print("[error] during moving downloaded log file. Error: \(error)")
        }

        _completed.accept(())
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didResumeAtOffset fileOffset: Int64,
                    expectedTotalBytes: Int64) {

        print("[didResumeAtOffset] fileOffset: \(fileOffset), expectedTotalBytes: \(expectedTotalBytes), downloadTask.state: \(downloadTask.state)")

    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {

        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) * 100

        print("[didWriteData] progress: \(progress), downloadTask.state: \(downloadTask.state)")

        _progress.accept(progress)
    }
}

private func mkdirIfNeeded(_ url: URL) {
    if !url.isFileURL {
        fatalError("non-file URL is not supported")
    }

    let fm = FileManager.default
    if fm.fileExists(atPath: url.path) {
        return
    }

    do {
        try fm.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    } catch {
        print("[error] during creating directory: \(error)")
    }

}
