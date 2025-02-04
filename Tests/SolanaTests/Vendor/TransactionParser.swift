import Foundation
import XCTest
@testable import RxSolana
import Solana

class TransactionParserTests: XCTestCase {
    let endpoint = RPCEndpoint.mainnetBetaSolana
    var solanaSDK: Solana!
    var parser: TransactionParser!
    
    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solanaSDK = Solana(router: NetworkingRouter(endpoint: endpoint), accountStorage: InMemoryAccountStorage())
        let account = Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solanaSDK.auth.save(account).get()
        
        parser = TransactionParser(solanaSDK: solanaSDK)
    }
    
    func testDecodingSwapTransaction() {
        let transactionInfo = transactionInfoFromJSONFileName("SwapTransaction")
        
        let myAccountSymbol = "SOL"
        let transaction = try! parser.parse(transactionInfo: transactionInfo, myAccount: nil, myAccountSymbol: myAccountSymbol)
            .toBlocking().first()?.value as! SwapTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "SRM")
        XCTAssertEqual(transaction.source?.pubkey, "BjUEdE292SLEq9mMeKtY3GXL6wirn7DqJPhrukCqAUua")
        XCTAssertEqual(transaction.sourceAmount, 0.001)
        
        XCTAssertEqual(transaction.destination?.token.symbol, myAccountSymbol)
        XCTAssertEqual(transaction.destinationAmount, 0.000364885)
    }
    
    func testDecodingCreateAccountTransaction() {
        let transactionInfo = transactionInfoFromJSONFileName("CreateAccountTransaction")
        
        let transaction = try! parser.parse(transactionInfo: transactionInfo, myAccount: nil, myAccountSymbol: nil)
            .toBlocking().first()?.value as! CreateAccountTransaction
        
        XCTAssertEqual(transaction.fee, 0.00203928)
        XCTAssertEqual(transaction.newWallet?.token.symbol, "ETH")
        XCTAssertEqual(transaction.newWallet?.pubkey, "8jpWBKSoU7SXz9gJPJS53TEXXuWcg1frXLEdnfomxLwZ")
    }
    
    func testDecodingCloseAccountTransaction()  {
        let transactionInfo = transactionInfoFromJSONFileName("CloseAccountTransaction")
        
        let transaction = try! parser.parse(transactionInfo: transactionInfo, myAccount: nil, myAccountSymbol: nil)
            .toBlocking().first()?.value as! CloseAccountTransaction
        
        XCTAssertEqual(transaction.reimbursedAmount, 0.00203928)
        XCTAssertEqual(transaction.closedWallet?.token.symbol, "ETH")
    }
    
    func testDecodingSendSOLTransaction() {
        let transactionInfo = transactionInfoFromJSONFileName("SendSOLTransaction")
        
        let myAccount = "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm"
        let transaction = try! parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: nil)
            .toBlocking().first()?.value as! TransferTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "SOL")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.destination?.pubkey, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        XCTAssertEqual(transaction.amount, 0.01)
    }
    
    func testDecodingSendSOLTransactionPaidByP2PORG() {
        let transactionInfo = transactionInfoFromJSONFileName("SendSOLTransactionPaidByP2PORG")
        
        let myAccount = "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm"
        let transaction = try! parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: nil)
            .toBlocking().first()?.value as! TransferTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "SOL")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.destination?.pubkey, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        XCTAssertEqual(transaction.amount, 0.00001)
    }
    
    func testDecodingSendSPLToSOLTransaction() {
        let transactionInfo = transactionInfoFromJSONFileName("SendSPLToSOLTransaction")
        let myAccount = "22hXC9c4SGccwCkjtJwZ2VGRfhDYh9KSRCviD8bs4Xbg"
        let transaction = try! parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: nil)
            .toBlocking().first()?.value as! TransferTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "wUSDT")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.destination?.pubkey, "GCmbXJRc6mfnNNbnh5ja2TwWFzVzBp8MovsrTciw1HeS")
        XCTAssertEqual(transaction.amount, 0.004325)
    }
    
    func testDecodingSendSPLToSPLTransaction() {
        let transactionInfo = transactionInfoFromJSONFileName("SendSPLToSPLTransaction")
        let myAccount = "BjUEdE292SLEq9mMeKtY3GXL6wirn7DqJPhrukCqAUua"
        let transaction = try! parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: nil)
            .toBlocking().first()?.value as! TransferTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "SRM")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.destination?.pubkey, "3YuhjsaohzpzEYAsonBQakYDj3VFWimhDn7bci8ERKTh")
        XCTAssertEqual(transaction.amount, 0.012111)
    }
    
    func testDecodingSendTokenToNewAssociatedTokenAddress() {
        // transfer type
        let transactionInfo = transactionInfoFromJSONFileName("SendTokenToNewAssociatedTokenAddress")
        let myAccount = "H1yu3R247X5jQN9bbDU8KB7RY4JSeEaCv45p5CMziefd"
        
        let transaction = try! parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: "MAPS")
            .toBlocking().first()?.value as! TransferTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "MAPS")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.amount, 0.001)
        
        // transfer checked type
        let transactionInfo2 = transactionInfoFromJSONFileName("SendTokenToNewAssociatedTokenAddressTransferChecked")
        let transaction2 = try! parser.parse(transactionInfo: transactionInfo2, myAccount: myAccount, myAccountSymbol: "MAPS")
            .toBlocking().first()?.value as! TransferTransaction
        
        XCTAssertEqual(transaction2.source?.token.symbol, "MAPS")
        XCTAssertEqual(transaction2.source?.pubkey, myAccount)
        XCTAssertEqual(transaction2.amount, 0.001)
    }
    
    func testDecodingProvideLiquidityToPoolTransaction() {
        // transfer type
        let transactionInfo = transactionInfoFromJSONFileName("ProvideLiquidityToPoolTransaction")
        let myAccount = "H1yu3R247X5jQN9bbDU8KB7RY4JSeEaCv45p5CMziefd"
        
        let transaction = try! parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: nil)
            .toBlocking().first()!
        
        XCTAssertNil(transaction.value)
    }
    
    func testDecodingBurnLiquidityInPoolTransaction() {
        // transfer type
        let transactionInfo = transactionInfoFromJSONFileName("BurnLiquidityInPoolTransaction")
        let myAccount = "H1yu3R247X5jQN9bbDU8KB7RY4JSeEaCv45p5CMziefd"
        
        let transaction = try! parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: nil)
            .toBlocking().first()!
        
        XCTAssertNil(transaction.value)
    }
    
    private func transactionInfoFromJSONFileName(_ name: String) -> TransactionInfo {
        //let path = Bundle(for: Self.self).path(forResource: name, ofType: "json")
        let data = stubbedResponse(name)
        let transactionInfo = try! JSONDecoder().decode(TransactionInfo.self, from: data)
        return transactionInfo
    }
}

func stubbedResponse(_ filename: String) -> Data {
    @objc class SolanaTests: NSObject { }
    let thisSourceFile = URL(fileURLWithPath: #file)
    let thisDirectory = thisSourceFile.deletingLastPathComponent()
    let resourceURL = thisDirectory.appendingPathComponent("../Resources/\(filename).json")
    return try! Data(contentsOf: resourceURL)
}
