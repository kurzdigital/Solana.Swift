import Foundation

public struct ConfirmedTransaction: Decodable {
    public let message: Message
    public let signatures: [String]
}
public struct ConfirmedTransactionFromBlock: Decodable {
    public let message: MessageWithAccountKeys
    public let signatures: [String]
}

public extension ConfirmedTransaction {
    struct Message: Decodable {
        public let accountKeys: [Account.Meta]
        public let instructions: [ParsedInstruction]
        public let recentBlockhash: String
    }
}
public extension ConfirmedTransactionFromBlock {
    struct MessageWithAccountKeys: Decodable {
        public let accountKeys: [String]
        public let instructions: [ParsedInstructionFromBlock]
        public let recentBlockhash: String
    }
}
public struct ParsedInstruction: Decodable {
    public struct Parsed: Decodable {
        public struct Info: Decodable {
            public let owner: String?
            public let account: String?
            public let source: String?
            public let destination: String?
            
            // create account
            public let lamports: UInt64?
            public let newAccount: String?
            public let space: UInt64?
            
            // initialize account
            public let mint: String?
            public let rentSysvar: String?
            
            // approve
            public let amount: String?
            // swiftlint:disable all
            public var delegate: String?
            
            // transfer
            public let authority: String?
            
            // transferChecked
            public let tokenAmount: TokenAccountBalance?
        }
        public let info: Info
        public let type: String?
    }
    
    public let program: String?
    public let programId: String?
    public let parsed: Parsed?
    
    // swap
    public let data: String?
    public let accounts: [String]?
}
public struct ParsedInstructionFromBlock: Decodable {
    public struct Parsed: Decodable {
        public struct Info: Decodable {
            public let owner: String?
            public let account: String?
            public let source: String?
            public let destination: String?
            
            // create account
            public let lamports: UInt64?
            public let newAccount: String?
            public let space: UInt64?
            
            // initialize account
            public let mint: String?
            public let rentSysvar: String?
            
            // approve
            public let amount: String?
            // swiftlint:disable all
            public var delegate: String?
            
            // transfer
            public let authority: String?
            
            // transferChecked
            public let tokenAmount: TokenAccountBalance?
        }
        public let info: Info
        public let type: String?
    }
    
    public let program: String?
    public let programId: String?
    public let parsed: Parsed?
    
    // swap
    public let data: String?
    public let accounts: [UInt64]?
}
