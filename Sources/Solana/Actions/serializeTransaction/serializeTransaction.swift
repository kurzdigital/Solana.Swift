import Foundation

extension Action {
    public func serializeTransaction(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        feePayer: PublicKey? = nil,
        onComplete: @escaping ((Result<String, Error>) -> Void)
    ) {

        guard let feePayer = try? feePayer ?? auth.account.get().publicKey else {
            onComplete(.failure(SolanaError.invalidRequest(reason: "Fee-payer not found")))
            return
        }

        let getRecentBlockhashRequest: (Result<String, Error>)->Void = { result in
            switch result {
            case .success(let recentBlockhash):

                var transaction = Transaction(
                    feePayer: feePayer,
                    instructions: instructions,
                    recentBlockhash: recentBlockhash
                )

                transaction.sign(signers: signers)
                .flatMap { transaction.serialize() }
                .flatMap {
                    let base64 = $0.bytes.toBase64()
                    return .success(base64)
                }
                .onSuccess { onComplete(.success($0)) }
            case .failure(let error):
                onComplete(.failure(error))
                return
            }
        }

        if let recentBlockhash = recentBlockhash {
            getRecentBlockhashRequest(.success(recentBlockhash))
        } else {
            self.api.getRecentBlockhash { getRecentBlockhashRequest($0) }
        }
    }
}
