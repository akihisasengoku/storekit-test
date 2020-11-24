//
//  StoreTransactionProcessor.swift
//  StoreKitDemo
//
//  Created by 仙石 晃久 on 2020/11/23.
//

import Foundation
import StoreKit

final class StoreTransactionProcessor {

    struct Dependency {
        let paymentQueue: SKPaymentQueue
        let validateReceiptGateway: ValidateReceiptGateway
        let paymentPurchaseObserver: StorePaymentPurchaseObserver

        static var `default`: Dependency {
            let paymentQueue = SKPaymentQueue.default()
            return Dependency(
                paymentQueue: paymentQueue,
                validateReceiptGateway: ValidateReceiptGateway(),
                paymentPurchaseObserver: StorePaymentPurchaseObserver(paymentQueue: paymentQueue)
            )
        }
    }

    static let shared = StoreTransactionProcessor(dependency: .default)

    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
        dependency.paymentQueue.add(dependency.paymentPurchaseObserver)
    }

    deinit {
        dependency.paymentQueue.remove(dependency.paymentPurchaseObserver)
    }

    func purchase(product: SKProduct, completion: @escaping (Result<StorePaymentTransactionState, StorePaymentError>) -> ()) {

        guard SKPaymentQueue.canMakePayments() else {
            completion(.failure(.paymentUnauthorized))
            return
        }

        guard dependency.paymentQueue.transactions.isEmpty else {
            completion(.failure(.hasUnfinishedTransaction))
            return
        }

        dependency.paymentPurchaseObserver.purchase(product: product) { [weak self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let state):
                switch state {
                case .purchased(let transaction):
                    self?.dependency.validateReceiptGateway.validate(transaction: transaction) { [weak self] result in
                        switch result {
                        case .failure(let error):
                            completion(.failure(error))
                        case .success:
                            self?.dependency.paymentQueue.finishTransaction(transaction)
                            completion(.success(.receiptVerificationSucceeded))
                        }
                    }
                default:
                    completion(.success(state))
                }
            }
        }
    }

    func resumeUnfinishedTransactions() {
        dependency.paymentQueue.transactions.forEach { transaction in
            print(transaction.transactionState)
            switch transaction.transactionState {
            case .failed:
                dependency.paymentQueue.finishTransaction(transaction)

            case .purchased:
                dependency.validateReceiptGateway.validate(transaction: transaction) { [weak self] result in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .success:
                        self?.dependency.paymentQueue.finishTransaction(transaction)
                    }
                }

            case .deferred, .purchasing, .restored:
                break

            @unknown default:
                break
            }
        }
    }
}
