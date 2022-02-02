import Foundation

public struct SolanaTokenAccountTokenAmount: Codable {
    public var amount: String?
    public var uiAmount: Double?
    public var decimals: Int?
    public var uiAmountString: String
}

public struct SolanaTokenAccountinfo: Codable {
    public var accountType: String?
    public var tokenAmount: SolanaTokenAccountTokenAmount?
    public var isInitialized: Bool?
    public var isNative: Bool?
    public var mint: String?
    public var owner: String?
}

public struct SolanaTokenAccountsparsed: Codable {
    public var type: String?
    public var info: SolanaTokenAccountinfo?
}

public struct SolanaTokenAccountsData: Codable {
    public var program: String?
    public var parsed: SolanaTokenAccountsparsed?
}

public struct SolanaTokenAccount: Codable {
    public var data: SolanaTokenAccountsData?
    public var executable: Bool?
    public var lamports: Int32?
    public var owner: String?
    public var rentEpoch: Int?
}

public struct SolanaTokenAccountsByOwnerValue: Codable {
    public var account: SolanaTokenAccount?
    public var pubkey: String?
    public var symbol: String?
}

public struct SolanaTokenAccountsByOwner: Codable {
    public var value: [SolanaTokenAccountsByOwnerValue]?
}
