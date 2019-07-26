import Foundation
//import RxCocoa
//import RxSwift

public func isTest() -> Bool {
    return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}

/// https://discuss.bitrise.io/t/build-logs-size-before-download/8614
//public func sizeRequestUsingZeroRange(_ url: URL) -> Observable<Int64> {
//    var req = URLRequest(url: url)
//    req.setValue("bytes=0-0", forHTTPHeaderField: "Range")
//
//    return URLSession.shared
//        .rx.response(request: req)
//        .flatMap { (res, _) -> Observable<Int64> in
//
//            if let resrange = res.allHeaderFields["Content-Range"] as? String {
//
//                // bytes 0-0/9553
//                if let total = resrange.split(separator: "/").last {
//
//                    let bf = ByteCountFormatter()
//                    bf.countStyle = .file
//
//                    if let bytes = Int64(String(total)) {
//                        return .just(bytes)
//                    }
//
//                }
//            }
//
//            return .empty()
//        }
//}
