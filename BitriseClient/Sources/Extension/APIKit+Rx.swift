import os.log
import APIKit
import RxSwift

extension Session: ReactiveCompatible { }

extension Reactive where Base: Session {
    func send<T: Request>(_ req: T) -> Observable<T.Response> {
        return Observable.create { o in
            let task = self.base.send(req) { result in
                switch result {
                case .success(let res):
                    o.onNext(res)
                    o.onCompleted()
                case .failure(let error):
                    if #available(iOS 12.0, *) {
                        os_log(.error, log: .network, "%{public}@ error: %{public}@", req.path, error.localizedDescription)
                    }
                    o.onError(error)
                }
            }
            return Disposables.create { [weak task] in
                task?.cancel()
            }
        }
    }
}
