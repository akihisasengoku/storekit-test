//
//  StoreTransactionProcessor.swift
//  StoreKitDemo
//
//  Created by 仙石 晃久 on 2020/11/23.
//

import Foundation
import StoreKit

final class StorePaymentManager {

    struct Dependency {
        let paymentQueue: SKPaymentQueue
        let validateReceiptGateway: ValidateReceiptGateway
        let paymentTransactionObserver: StorePaymentTransactionObserver

        static var `default`: Dependency {
            let paymentQueue = SKPaymentQueue.default()
            return Dependency(
                paymentQueue: paymentQueue,
                validateReceiptGateway: ValidateReceiptGateway(),
                paymentTransactionObserver: StorePaymentTransactionObserver(paymentQueue)
            )
        }
    }

    static let shared = StorePaymentManager(dependency: .default)
    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency

        dependency.paymentTransactionObserver.observe()
    }

    deinit {
        dependency.paymentTransactionObserver.completeObservation()
    }

    var appStoreReceipt: String? {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: appStoreReceiptURL) else {
            return nil
        }
        return receiptData.base64EncodedString()
    }

    /// プロダクトの購入を行う
    func purchase(product: SKProduct, completion: @escaping (Result<StorePaymentTransactionState, StorePaymentError>) -> Void) {
        /// 端末で課金が許可されていない
        guard SKPaymentQueue.canMakePayments() else {
            completion(.failure(.paymentUnauthorized))
            return
        }

        /// 処理中のトランザクションがある場合は購入を行わない
        guard dependency.paymentQueue.transactions.isEmpty else {
            completion(.failure(.hasUnfinishedTransaction))
            return
        }

        dependency.paymentTransactionObserver.purchase(product: product) { [weak self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let state):
                switch state {
                case .purchased(let transaction):
                    self?.validateReceipt(transaction: transaction, completion: completion)
                default:
                    completion(.success(state))
                }
            }
        }
    }

    /// 未完了のトランザクションの処理を行う
    func resumeUnfinishedTransactions() {
        dependency.paymentQueue.transactions.forEach { transaction in
            switch transaction.transactionState {
            case .failed:
                dependency.paymentQueue.finishTransaction(transaction)

            case .purchased:
                validateReceipt(transaction: transaction) { result in
                    print(result)
                }

            case .deferred, .purchasing, .restored:
                break

            @unknown default:
                break
            }
        }
    }

    /// レシート検証を行う
    private func validateReceipt(transaction: SKPaymentTransaction, completion: @escaping (Result<StorePaymentTransactionState, StorePaymentError>) -> Void) {
        dependency.validateReceiptGateway.validate(transaction: transaction) { [weak self] result in
            switch result {
            case .failure(let error):
                let paymentError = StorePaymentError.validateReceiptFailed(error)
                completion(.failure(paymentError))
            case .success:
                /// レシート検証成功後にトランザクションを終了する
                self?.dependency.paymentQueue.finishTransaction(transaction)
                completion(.success(.receiptVerificationSucceeded))
            }
        }
    }
}
