import Foundation

public extension Api {
    func getRecentBlockhash(commitment: Commitment? = nil, onComplete: @escaping(Result<String, Error>)->Void) {
        router.request(parameters: [RequestConfiguration(commitment: commitment)]) { (result: Result<Rpc<Fee?>, Error>) in
            switch result {
            case .success(let rpc):
                guard let value = rpc.value else {
                    onComplete(.failure(SolanaError.nullValue))
                    return
                }
                guard let blockhash = value.blockhash else {
                    onComplete(.failure(SolanaError.blockHashNotFound))
                    return
                }
                onComplete(.success(blockhash))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
