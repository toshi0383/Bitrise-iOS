import os.log
import APIKit
import Core
import Foundation
import RxCocoa
import RxSwift

final class BitriseYmlViewModel {

    enum EditState {
        case initial
        case editing
        case saving // loading
    }

    // MARK: Output

    let ymlPayload: Property<String>
    private let _ymlPayload = BehaviorRelay<String>(value: "")

    let editState: Property<EditState>
    private let _editState = BehaviorRelay<EditState>(value: .initial)

    let alertMessage: Observable<String>
    private let _alertMessage = PublishRelay<String>()

    let appName: String

    // MARK: Input

    private let appSlug: AppSlug

    // MARK: Private

    private let disposeBag = DisposeBag()

    // MARK: Initialize

    init(appSlug: AppSlug, appName: String) {
        self.appSlug = appSlug
        self.appName = appName
        self.ymlPayload = Property(_ymlPayload)
        self.editState = Property(_editState)
        self.alertMessage = _alertMessage.asObservable()

        let req = GetBitriseYmlRequest(appSlug: appSlug)

        Session.shared.rx.send(req)
            .map {$0.ymlPayload }
            .bind(to: _ymlPayload)
            .disposed(by: disposeBag)
    }

    // MARK: API

    func editSaveButtonTap() {
        switch editState.value {
        case .initial:
            // start editing
            _editState.accept(.editing)
            break
        case .saving:
            // ignore
            break
        case .editing:

            _editState.accept(.saving)

            // TODO: fetch, compare and check for any conflicts?
            let req = PostBitriseYmlRequest(appSlug: appSlug, ymlString: ymlPayload.value)

            Session.shared.rx.send(req)
                .take(1)
                .catchError({ [weak self] error in
                    self?._alertMessage.accept("Yml Upload Error: \(error)")
                    return .empty()
                })
                .map { _ in .initial }
                .bind(to: _editState)
                .disposed(by: disposeBag)
        }
    }
}
