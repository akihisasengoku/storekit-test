//
//  StorePaymentTransactionObserver.swift
//  StoreKitDemo
//
//  Created by 仙石 晃久 on 2020/11/23.
//

import StoreKit

protocol StorePaymentTransactionObserverProtocol: AnyObject {

}

final class StorePaymentTransactionObserver: NSObject, StorePaymentTransactionObserverProtocol {
    private let paymentQueue: SKPaymentQueue

    private var eventHandler: ((Result<StorePaymentTransactionState, StorePaymentError>) -> Void)?
    private var product: SKProduct?

    init(_ paymentQueue: SKPaymentQueue) {
        self.paymentQueue = paymentQueue
        super.init()
    }

    func purchase(product: SKProduct, completion: @escaping ((Result<StorePaymentTransactionState, StorePaymentError>) -> Void)) {
        self.product = product
        self.eventHandler = completion

        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func observe() {
        paymentQueue.add(self)
    }

    func completeObservation() {
        paymentQueue.remove(self)
    }
}

extension StorePaymentTransactionObserver: SKPaymentTransactionObserver {
    func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        guard let transaction = transactions.first(where: { $0.payment.productIdentifier == product?.productIdentifier }) else {
            eventHandler?(.failure(StorePaymentError.notFoundItem))
            return
        }

        switch transaction.transactionState {
        case .purchasing:
            eventHandler?(.success(.purchasing))

        case .purchased:
            eventHandler?(.success(.purchased(transaction)))

        case .failed where (transaction.error as? SKError)?.code == .paymentCancelled:
            // Only display errors whose code is different from paymentCancelled.
            // - SeeAlso: https://developer.apple.com/documentation/storekit/in-app_purchase/offering_completing_and_restoring_in-app_purchases
            paymentQueue.finishTransaction(transaction)
            eventHandler?(.success(.cancelled))

        case .failed:
            paymentQueue.finishTransaction(transaction)
            let error: StorePaymentError = transaction.error.map { .appStoreTransactionFailed($0) } ?? .unknown
            eventHandler?(.failure(error))

        case .deferred:
            eventHandler?(.success(.deferred))

        default:
            eventHandler?(.success(.unknown))
        }
    }

    func paymentQueue(_: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        eventHandler?(.success(.removedTransactions))
    }
}
