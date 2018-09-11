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
                case .failure(let err):
                    o.onError(err)
                }
            }
            return Disposables.create { [weak task] in
                task?.cancel()
            }
        }
    }
}
