// Generated using Sourcery 0.13.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


// swiftlint:disable file_length
fileprivate func compareOptionals<T>(lhs: T?, rhs: T?, compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    switch (lhs, rhs) {
    case let (lValue?, rValue?):
        return compare(lValue, rValue)
    case (nil, nil):
        return true
    default:
        return false
    }
}

fileprivate func compareArrays<T>(lhs: [T], rhs: [T], compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (idx, lhsItem) in lhs.enumerated() {
        guard compare(lhsItem, rhs[idx]) else { return false }
    }

    return true
}

// MARK: - AutoEquatable for classes, protocols, structs
// MARK: - AppsBuilds.Build AutoEquatable
extension AppsBuilds.Build: Equatable {} 
internal func == (lhs: AppsBuilds.Build, rhs: AppsBuilds.Build) -> Bool {
    guard compareOptionals(lhs: lhs.abort_reason, rhs: rhs.abort_reason, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.branch, rhs: rhs.branch, compare: ==) else { return false }
    guard lhs.build_number == rhs.build_number else { return false }
    guard compareOptionals(lhs: lhs.commit_hash, rhs: rhs.commit_hash, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.commit_message, rhs: rhs.commit_message, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.commit_view_url, rhs: rhs.commit_view_url, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.environment_prepare_finished_at, rhs: rhs.environment_prepare_finished_at, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.finished_at, rhs: rhs.finished_at, compare: ==) else { return false }
    guard lhs.is_on_hold == rhs.is_on_hold else { return false }
    guard compareOptionals(lhs: lhs.pull_request_id, rhs: rhs.pull_request_id, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.pull_request_target_branch, rhs: rhs.pull_request_target_branch, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.pull_request_view_url, rhs: rhs.pull_request_view_url, compare: ==) else { return false }
    guard lhs.slug == rhs.slug else { return false }
    guard compareOptionals(lhs: lhs.stack_config_type, rhs: rhs.stack_config_type, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.stack_identifier, rhs: rhs.stack_identifier, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.started_on_worker_at, rhs: rhs.started_on_worker_at, compare: ==) else { return false }
    guard lhs.status == rhs.status else { return false }
    guard lhs.status_text == rhs.status_text else { return false }
    guard compareOptionals(lhs: lhs.tag, rhs: rhs.tag, compare: ==) else { return false }
    guard lhs.triggered_at == rhs.triggered_at else { return false }
    guard compareOptionals(lhs: lhs.triggered_by, rhs: rhs.triggered_by, compare: ==) else { return false }
    guard lhs.triggered_workflow == rhs.triggered_workflow else { return false }
    return true
}

// MARK: - AutoEquatable for Enums

// MARK: -
