import os.log
import APIKit
import Core
import DeepDiff
import RxSwift
import UIKit

final class BuildsListViewController: UIViewController, Storyboardable {

    private var dataSource: BuildsListDataSource!

    private var viewModel: BuildsListViewModel! {
        didSet {
            dataSource = BuildsListDataSource(viewModel: viewModel)
        }
    }

    // MARK: UI components

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = dataSource
        }
    }

    @IBOutlet private weak var triggerBuildButton: UIButton! {
        didSet {
            triggerBuildButton.layer.cornerRadius = triggerBuildButton.frame.width / 2
        }
    }

    @IBOutlet private weak var bitriseYmlButton: UIButton! {
        didSet {
            bitriseYmlButton.layer.cornerRadius = bitriseYmlButton.frame.width / 2
        }
    }

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        return refreshControl
    }()

    // MARK: Utilities

    private var visibleBuilds: [AppsBuilds.Build] {
        guard let indexPaths = tableView.indexPathsForVisibleRows else { return [] }

        return indexPaths.map { viewModel.builds[$0.row] }
    }

    private var alphaChangingViews: [UIView] {
        return [triggerBuildButton, bitriseYmlButton]
    }

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.navigationBarTitle

        viewModel.alertMessage
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: { [weak self] msg in
                self?.alert(msg)
            })
            .disposed(by: rx.disposeBag)

        viewModel.alertActions.asObservable()
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: { [weak self] alertActions in
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

                for action in alertActions {
                    actionSheet.addAction(UIAlertAction(title: action.title,
                                                        style: action.style,
                                                        handler: action.handler))
                }

                self?.present(actionSheet, animated: true, completion: nil)

            })
            .disposed(by: rx.disposeBag)

        viewModel.dataChanges.changed
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: { [weak self] changes in
                self?.tableView.reload(changes: changes, completion: { _ in })
            })
            .disposed(by: rx.disposeBag)

        viewModel.isNewDataIndicatorHidden.asObservable()
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: { [weak self] isHidden in
                guard let me = self else { return }

                if isHidden {
                    me.refreshControl.endRefreshing()
                } else {
                    me.refreshControl.beginRefreshing()
                }
            })
            .disposed(by: rx.disposeBag)

        // Make buttons transparent while scrolling.

        let didEndDragging = tableView.rx.didEndDragging

        tableView.rx.willBeginDragging
            .map { _ in CGFloat(0.1) }
            .flatMapLatest {
                Observable.just($0)
                    .concat(
                        didEndDragging
                            .map { _ in CGFloat(1.0) }
                            .delay(0.5, scheduler: ConcurrentMainScheduler.instance)
                    )
            }
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: { [weak self] alpha in
                self?.alphaChangingViews.forEach { $0.alpha = alpha }
            })
            .disposed(by: rx.disposeBag)

        tableView.rx.itemAccessoryButtonTapped
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.tappedAccessoryButtonIndexPath(indexPath)
            })
            .disposed(by: rx.disposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: rx.disposeBag)

        tableView.rx.didScroll
            .subscribe(onNext: { [weak self] _ in
                guard let viewModel = self?.viewModel, let tableView = self?.tableView else {
                    return
                }

                viewModel.updateScrollInfo(contentHeight: tableView.contentSize.height,
                                           contentOffsetY: tableView.contentOffset.y,
                                           frameHeight: tableView.frame.height,
                                           adjustedContentInsetBottom: tableView.adjustedContentInset.bottom)
            })
            .disposed(by: rx.disposeBag)

        // Reset BuildPollingManager.targets

        tableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] event in
                guard let me = self else { return }

                let visibleBuilds = me.visibleBuilds
                let buildPollingManager = me.viewModel.buildPollingManager

                for buildSlug in buildPollingManager.targets {

                    if !visibleBuilds.contains(where: { $0.slug == buildSlug }) {

                        // NOTE: Polling won't be cancelled if localNotification is registered.
                        buildPollingManager.removeTarget(buildSlug: buildSlug)

                    }
                }

                for visibleBuild in visibleBuilds.filter({ $0.status == .notFinished }) {

                    if !buildPollingManager.targets.contains(where: { $0 == visibleBuild.slug }) {

                        buildPollingManager.addTarget(buildSlug: visibleBuild.slug)

                    }

                }
            })
            .disposed(by: rx.disposeBag)

    }

    // MARK: Action

    @IBAction func bitriseYmlButtonTap() {
        let vm = BitriseYmlViewModel(appSlug: viewModel.appSlug, appName: viewModel.navigationBarTitle)
        let vc = BitriseYmlViewController(viewModel: vm)

        vc.modalPresentationStyle = .overCurrentContext

        navigationController?.present(vc, animated: true, completion: nil)
    }

    @IBAction func triggerBuildButtonTap() {
        Haptic.generate(.light)

        let logicStore = TriggerBuildViewModel(appSlug: viewModel.appSlug)
        let vc = TriggerBuildViewController.makeFromStoryboard(logicStore)

        vc.modalPresentationStyle = .overCurrentContext

        navigationController?.present(vc, animated: true, completion: nil)

        logicStore.buildDidTrigger
            .subscribe(onNext: { [weak viewModel] _ in
                viewModel?.fetchBuilds(.new)
            })
            .disposed(by: vc.rx.disposeBag)
    }

    @objc private func pullToRefresh() {
        viewModel.fetchBuilds(.new)
    }

}

// - MARK: Storyboardable

extension BuildsListViewController {

    struct Dependency {
        let viewModel: BuildsListViewModel
    }

    static func makeFromStoryboard(_ dependency: Dependency) -> BuildsListViewController {
        let vc = BuildsListViewController.unsafeMakeFromStoryboard()
        vc.viewModel = dependency.viewModel
        vc.viewModel.lifecycle = vc.lifecycle
        return vc
    }

}
