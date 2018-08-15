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

    // MARK: Initialize

    init(appSlug: AppSlug, appName: String) {
        self.appSlug = appSlug
        self.appName = appName
        self.ymlPayload = Property(_ymlPayload)
        self.editState = Property(_editState)
        self.alertMessage = _alertMessage.asObservable()

        let req = GetBitriseYmlRequest(appSlug: appSlug)
        Session.shared.send(req) { [weak self] r in
            guard let me = self else { return }

            switch r {
            case .success(let value):
                me._ymlPayload.accept(value.ymlPayload)
            case .failure(let error):
                fatalError("ERROR: \(error)")
            }
        }
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

            // TODO: fetch, compare and check for any conflicts
            let req = PostBitriseYmlRequest(appSlug: appSlug, ymlString: ymlPayload.value)
            Session.shared.send(req) { [weak self] result in
                guard let me = self else { return }

                switch result {
                case .success:
                    // me._alertMessage.accept("Yml Upload Success!")
                    me._editState.accept(.initial)

                case .failure(let error):
                    me._alertMessage.accept("Yml Upload Error: \(error)")
                }
            }
        }
    }
}
