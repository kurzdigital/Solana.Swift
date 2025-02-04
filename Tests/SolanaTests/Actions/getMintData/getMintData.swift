import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class getMintData: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solana: Solana!
    var account: Account { try! solana.auth.account.get() }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solana = Solana(router: NetworkingRouter(endpoint: endpoint), accountStorage: InMemoryAccountStorage())
        let account = Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solana.auth.save(account).get()
    }
    
    func testGetMintData() {
        let data = try! solana.action.getMintData(mintAddress: PublicKey(string: "8wzZaGf89zqx7PRBoxk9T6QyWWQbhwhdU555ZxRnceG3")!).toBlocking().first()
        XCTAssertNotNil(data)
    }
    
    func testGetMultipleMintDatas() {
        let datas = try! solana.action.getMultipleMintDatas(mintAddresses: [PublicKey(string: "8wzZaGf89zqx7PRBoxk9T6QyWWQbhwhdU555ZxRnceG3")!]).toBlocking().first()
        XCTAssertNotNil(datas)
    }
    
    func testGetPools() {
        let pools = try! solana.action.getSwapPools().toBlocking().first()
        XCTAssertNotNil(pools)
        XCTAssertNotEqual(pools!.count, 0)
    }
    func testMintToInstruction() {
        let publicKey = PublicKey(string: "11111111111111111111111111111111")!
        let instruction = TokenProgram.mintToInstruction(tokenProgramId: publicKey, mint: publicKey, destination: publicKey, authority: publicKey, amount: 1000000000)
        XCTAssertEqual("6AsKhot84V8s", Base58.encode(instruction.data))
    }
}
