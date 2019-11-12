import RxSwift
import BitriseSwift

extension APIClient: ReactiveCompatible { }

extension Reactive where Base: APIClient {
    public func makeRequest<Response>(_ request: APIRequest<Response>) -> Observable<Response.SuccessType> {
        return Observable.create { o in
            let cancellable = self.base.makeRequest(request, complete: {
                switch $0.result {
                case .success(let value):
                    if let t = value.success {
                        o.onNext(t)
                        o.onCompleted()
                    } else {
                        fatalError()
                    }
                case .failure(let apierror):
                    o.onError(apierror)
                }
            })

            return Disposables.create {
                cancellable?.cancel()
            }
        }
    }
}
