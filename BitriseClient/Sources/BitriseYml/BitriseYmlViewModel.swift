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

    let appName: String

    // MARK: Input

    private let appSlug: AppSlug

    // MARK: Initialize

    init(appSlug: AppSlug, appName: String) {
        self.appSlug = appSlug
        self.appName = appName
        self.ymlPayload = Constant(variable: _ymlPayload)
        self.editState = Constant(variable: _editState)

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
            // TODO: fetch, compare and save if no conflicts
            _editState.value = .initial
//            let req = PostBitriseYmlRequest(appSlug: appSlug, data: bitriseYml.data`)
//            Session.shared.send(<#T##request: Request##Request#>)
            break
        }
    }
}
