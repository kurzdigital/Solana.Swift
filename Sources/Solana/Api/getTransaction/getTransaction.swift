import Foundation

public extension Api {
    func getTransaction(transactionSignature: String, onComplete: @escaping (Result<TransactionInfo, Error>) -> Void) {
        router.request(parameters: [transactionSignature, "jsonParsed"]) { (result: Result<TransactionInfo, Error>) in
            switch result {
            case .success(let transactions):
                onComplete(.success(transactions))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
