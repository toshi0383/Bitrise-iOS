//
//  BitriseYmlViewModel.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/04/21.
//

import APIKit
import Continuum
import Foundation

final class BitriseYmlViewModel {

    enum EditState {
        case initial
        case editing
        case saving // loading
    }

    // MARK: Output

    let ymlPayload: Constant<String>
    private let _ymlPayload = Variable<String>(value: "")

    let editState: Constant<EditState>
    private let _editState = Variable<EditState>(value: .initial)

    let alertMessage: Constant<String>
    private let _alertMessage = Variable<String>(value: "")

    let appName: String

    // MARK: Input

    private let appSlug: AppSlug

    // MARK: Initialize

    init(appSlug: AppSlug, appName: String) {
        self.appSlug = appSlug
        self.appName = appName
        self.ymlPayload = Constant(variable: _ymlPayload)
        self.editState = Constant(variable: _editState)
        self.alertMessage = Constant(variable: _alertMessage)

        let req = GetBitriseYmlRequest(appSlug: appSlug)
        Session.shared.send(req) { [weak self] r in
            guard let me = self else { return }

            switch r {
            case .success(let value):
                me._ymlPayload.value = value.ymlPayload
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
            _editState.value = .editing
            break
        case .saving:
            // ignore
            break
        case .editing:

            _editState.value = .saving

            // TODO: fetch, compare and check for any conflicts
            let req = PostBitriseYmlRequest(appSlug: appSlug, ymlString: ymlPayload.value)
            Session.shared.send(req) { [weak self] result in
                guard let me = self else { return }

                switch result {
                case .success:
                    // me._alertMessage.value = "Yml Upload Success!"
                    me._editState.value = .initial

                case .failure(let error):
                    me._alertMessage.value = "Yml Upload Error: \(error)"
                }
            }
        }
    }
}
