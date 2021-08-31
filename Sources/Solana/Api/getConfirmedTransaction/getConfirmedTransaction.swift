import Foundation

public extension Api {
    func getConfirmedTransaction(transactionSignature: String, commitment: Commitment? = nil, onComplete: @escaping (Result<TransactionInfo, Error>) -> Void) {
        router.request(parameters: [transactionSignature, RequestConfiguration(commitment: commitment, encoding: "jsonParsed")]) { (result: Result<TransactionInfo, Error>) in
            switch result {
            case .success(let transactions):
                onComplete(.success(transactions))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
    
   func getConfirmedTransactions(transactionSignatures: [String], commitment: Commitment? = nil, onComplete: @escaping (Result<[Response<TransactionInfo>], Error>) -> Void) {
        let configs = RequestConfiguration(commitment: commitment, encoding: "jsonParsed")
        var array: [[Encodable]] = []
        for signature in transactionSignatures {
            array.append([signature, configs])
        }
        
        router.batchRequest(bcMethod: "getConfirmedTransaction", batchParameters: array) { (result: Result<[Response<TransactionInfo>], Error>) in
            switch result {
            case .success(let responses):
                onComplete(.success(responses))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

