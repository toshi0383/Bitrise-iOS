import os.log

extension OSLog {
    public static let network = OSLog(subsystem: "jp.toshi0383.Bitrise-iOS.Core", category: "Network")

    @available(iOS 12.0, *)
    public static let pointsOfInterest = OSLog(subsystem: "jp.toshi0383.Bitrise-iOS", category: .pointsOfInterest)
}
