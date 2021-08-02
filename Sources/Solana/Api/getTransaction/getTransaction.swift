import Foundation

public extension Api {
    func getTransaction(transactionSignature: String, commitment: Commitment? = nil, onComplete: @escaping (Result<TransactionInfo, Error>) -> Void) {
        router.request(parameters: [transactionSignature, "jsonParsed", RequestConfiguration(commitment: commitment)]) { (result: Result<TransactionInfo, Error>) in
            switch result {
            case .success(let transactions):
                onComplete(.success(transactions))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
