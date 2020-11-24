//
//  StorePaymentPurchaseGateway.swift
//  StoreKitDemo
//
//  Created by 仙石 晃久 on 2020/11/23.
//

import StoreKit

final class StorePaymentPurchaseObserver: NSObject {

    private let paymentQueue: SKPaymentQueue

    private var completion: ((Result<StorePaymentTransactionState, StorePaymentError>) -> Void)?
    private var product: SKProduct?

    init(paymentQueue: SKPaymentQueue) {
        self.paymentQueue = paymentQueue
        super.init()
    }

    func purchase(product: SKProduct, completion: @escaping ((Result<StorePaymentTransactionState, StorePaymentError>) -> Void)) {
        self.completion = completion
        self.product = product

        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

extension StorePaymentPurchaseObserver: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

        guard let transaction = transactions.first(where: { $0.payment.productIdentifier == product?.productIdentifier }) else {
            completion?(.failure(StorePaymentError.notFoundItem))
            return
        }

        switch transaction.transactionState {
        case .purchasing:
            completion?(.success(.purchasing))

        case .purchased:
            completion?(.success(.purchased(transaction)))

        case .failed where (transaction.error as? SKError)?.code == .paymentCancelled:
            // Only display errors whose code is different from paymentCancelled.
            // - SeeAlso: https://developer.apple.com/documentation/storekit/in-app_purchase/offering_completing_and_restoring_in-app_purchases
            paymentQueue.finishTransaction(transaction)
            completion?(.success(.cancelled))

        case .failed:
            paymentQueue.finishTransaction(transaction)
            let error: StorePaymentError = transaction.error.map { .appStoreTransactionFailed($0) } ?? .unknown
            completion?(.failure(error))

        case .deferred:
            completion?(.success(.deferred))

        default:
            break
        }
    }
}
