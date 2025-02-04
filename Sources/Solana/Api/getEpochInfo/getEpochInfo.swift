import Foundation

public extension Api {
    func getEpochInfo(commitment: Commitment? = nil, onComplete: @escaping ((Result<EpochInfo, Error>) -> Void)) {
        router.request(parameters: [RequestConfiguration(commitment: commitment)]) { (result: Result<EpochInfo, Error>) in
            switch result {
            case .success(let epoch):
                onComplete(.success(epoch))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
