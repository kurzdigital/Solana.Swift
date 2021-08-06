import Foundation

public extension Api {
    func getTransaction(transactionSignature: String, commitment: Commitment? = nil, onComplete: @escaping (Result<TransactionInfo, Error>) -> Void) {
        let configs = RequestConfiguration(commitment: commitment, encoding: "jsonParsed")
        router.request(parameters: [transactionSignature, configs]) { (result: Result<TransactionInfo, Error>) in
            switch result {
            case .success(let transactions):
                onComplete(.success(transactions))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
    
    func getTransactions(transactionSignatures: [String], commitment: Commitment? = nil, onComplete: @escaping (Result<[Response<TransactionInfo>], Error>) -> Void) {
        let configs = RequestConfiguration(commitment: commitment, encoding: "jsonParsed")
        var array: [[Encodable]] = []
        for signature in transactionSignatures {
            array.append([signature, configs])
        }
        
        router.batchRequest(bcMethod: "getTransaction", batchParameters: array) { (result: Result<[Response<TransactionInfo>], Error>) in
            switch result {
            case .success(let responses):
                onComplete(.success(responses))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
