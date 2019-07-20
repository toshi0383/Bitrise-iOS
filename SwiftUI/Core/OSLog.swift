import os.log

extension OSLog {
    public static let network = {
        ProcessInfo.processInfo.environment["ENABLE_SIGNPOST"] == "YES"
            ? OSLog(subsystem: "jp.toshi0383.Bitrise-iOS.Core", category: "Network")
            : .disabled
    }()

    @available(iOS 12.0, *)
    public static let pointsOfInterest = {
        ProcessInfo.processInfo.environment["ENABLE_SIGNPOST"] == "YES"
            ? OSLog(subsystem: "jp.toshi0383.Bitrise-iOS", category: .pointsOfInterest)
            : .disabled
    }()

}
