# Solana SDK
[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.png?v=103)](https://opensource.org/licenses/mit-license.php)  

This is a open source library on pure swift for Solana protocol.
It is based on the work from https://github.com/ajamaica/Solana.Swift but streamlined for usage without RxSwift dependency.


# Features
- [x] Sign and send transactions.
- [x] Key pair generation
- [x] RPC configuration.
- [x] SPM integration
- [x] Few libraries requirement (TweetNACL)
- [x] Fully tested (53%)


# Usage

### Initialization
Set the NetworkingRouter and setup your enviroment. You can also pass your own **URLSession** with your own settings. Use this router to initialize the sdk with an object that conforms the SolanaAccountStorage protocol
```swift
let network = NetworkingRouter(endpoint: .devnetSolana)
let solana = Solana(router: network, accountStorage: self.accountStorage)
```
### Keypair generation

SolanaAccountStorage interface is used to return the generated accounts. The actual storage of the accout is handled by the client. Please make sure this account is stored correctly (you can encrypt it on the keychain). The retrived accout is Serializable. Inside Account you will fine the phrase, publicKey and secretKey.

### RPC api calls

We support [45](https://github.com/ajamaica/Solana.Swift/tree/master/Sources/Solana/Api "Check the Api folder") rpc api calls with and without Rx. Normal calls will return a callback (onComplete) and RxSolana will return Single  . If the call requires address in base58 format, if is null it will default to the one returned by SolanaAccountStorage.

Example using callback

Gets Accounts info.
```swift
solana.api.getAccountInfo(account: account.publicKey.base58EncodedString, decodedTo: AccountInfo.self) { result in
// process result
}
```
Gets Balance
```swift
 solana.api.getBalance(account: account.publicKey.base58EncodedString){ result in
 // process result
 }
```

### Actions

Actions are predifined program interfaces that construct the required inputs for the most common tasks in Solana ecosystems. You can see them as bunch of code that implements solana task using rpc calls. This also support optional Rx

We support 12.
- closeTokenAccount: Closes token account
- getTokenWallets: get token accounts
- createAssociatedTokenAccount: Opens associated token account
- sendSOL : Sends SOL native token
- createTokenAccount: Opens token account
- sendSPLTokens: Sends tokens
- findSPLTokenDestinationAddress : Finds address of a token of a address
- **serializeAndSendWithFee**: Serializes and signs the transaction. Then it it send to the blockchain.
- getMintData: Get mint data for token
- serializeTransaction: Serializes transaction
- getPools: Get all available pools. Very intensive
- swap: Swaps 2 tokens from pool.

#### Example with callback

Create an account token

```swift
solana.action.createTokenAccount( mintAddress: mintAddress) { result in
// process
}
```
Sending sol
```swift
let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
let transactionId = try! solana.action.sendSOL(
            to: toPublicKey,
            amount: 10
){ result in
 // process
}
```

## Requirements

- iOS 11.0+ / macOS 10.13+ / tvOS 11.0+ / watchOS 3.0+
- Swift 5.3+

## Installation

From Xcode 11, you can use [Swift Package Manager](https://swift.org/package-manager/) to add Solana.swift to your project.

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/kurzdigital/Solana.Swift`
- Select "brach" with "master"
- Select Solana and RxSwift (fully optional)

If you encounter any problem or have a question on adding the package to an Xcode project, I suggest reading the [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)  guide article from Apple.

## Other

### Ideas and plans

The code and api will be evoling for this initial fork please keep that in mind. I am planning adding support for othr development layers like React Native or flutter.

RxSwift maybe be removed from the library or at least moved to a diferent sublibrary. Every call will have a unit test.


