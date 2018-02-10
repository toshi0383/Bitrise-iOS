//
//  GitObject.swift
//  BitriseClient
//
//  Created by Toshihiro Suzuki on 2018/02/10.
//

import Foundation

enum GitObject {

    case branch(String), tag(String), commitHash(String)

    var json: [String: String] {
        switch self {
        case .branch(let v): return ["branch": v]
        case .tag(let v): return ["tag": v]
        case .commitHash(let v): return ["commit": v]
        }
    }

    static func enumerated() -> [GitObject] {
        return [.branch(""), .tag(""), .commitHash("")]
    }

    func updateAssociatedValue(_ value: String) -> GitObject {
        switch self {
        case .branch: return .branch(value)
        case .tag: return .tag(value)
        case .commitHash: return .commitHash(value)
        }
    }
}
