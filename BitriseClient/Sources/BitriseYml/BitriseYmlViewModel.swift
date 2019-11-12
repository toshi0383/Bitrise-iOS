import os.log
import BitriseSwift
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
        let _ymlPayload = BehaviorRelay<String>(value: "")

        self.appSlug = appSlug
        self.appName = appName
        self.ymlPayload = Property(_ymlPayload)
        self.editState = Property(_editState)
        self.alertMessage = _alertMessage.asObservable()

        let req = API.Application.AppConfigDatastoreShow.Request(appSlug: appSlug)

        APIClient.default.rx.makeRequest(req)
            .catchErrorJustReturn("Couldn't retrieve data.")
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

            let req = API.AppSetup.AppConfigCreate.Request(appSlug: appSlug,
                                                           body: .init(appConfigDatastoreYaml: ymlPayload.value))

            APIClient.default.rx.makeRequest(req)
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
