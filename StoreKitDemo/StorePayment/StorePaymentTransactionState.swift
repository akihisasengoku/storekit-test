//
//  StoreTransactionState.swift
//  StoreKitDemo
//
//  Created by 仙石 晃久 on 2020/11/23.
//

import StoreKit

enum StorePaymentTransactionState {
    case deferred
    case purchasing
    case purchased(SKPaymentTransaction)
    case receiptVerificationSucceeded
    case cancelled
    case unknown
    case removedTransactions

    var localizedDescription: String {
        switch self {
        case .deferred:
            return "deferred"
        case .purchasing:
            return "purchasing"
        case .purchased:
            return "purchased"
        case .receiptVerificationSucceeded:
            return "receiptVerificationSucceeded"
        case .cancelled:
            return "cancelled"
        case .unknown:
            return "unknown"
        case .removedTransactions:
            return "removedTransactions"
        }
    }
}
