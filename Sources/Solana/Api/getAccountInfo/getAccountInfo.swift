import Foundation

public extension Api {
    func getAccountInfo<T: BufferLayout>(account: String, commitment: Commitment? = nil, decodedTo: T.Type, onComplete: @escaping(Result<BufferInfo<T>, Error>) -> Void) {
        let configs = RequestConfiguration(commitment: commitment, encoding: "base64")
        router.request(parameters: [account, configs]) {  (result: Result<Rpc<BufferInfo<T>?>, Error>) in
            switch result {
            case .success(let rpc):
                guard let value = rpc.value else {
                    onComplete(.failure(SolanaError.nullValue))
                    return
                }
                onComplete(.success(value))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
