//
//  StorePaymentError.swift
//  StoreKitDemo
//
//  Created by 仙石 晃久 on 2020/11/23.
//

enum StorePaymentError: Error {
    case notFoundItem
    case sendReceiptError
    case receiveResponseError
    case hasUnfinishedTransaction
    case appStoreTransactionFailed(Error)
    case paymentUnauthorized
    case unknown

    var localizedDescription: String {
        switch self {
        case .notFoundItem:
            return "notFoundItem"
        case .sendReceiptError:
            return "sendReceiptError"
        case .receiveResponseError:
            return "receiveResponseError"
        case .hasUnfinishedTransaction:
            return "hasUnfinishedTransaction"
        case .appStoreTransactionFailed(let error):
            return "appStoreTransactionFailed \(error.localizedDescription)"
        case .paymentUnauthorized:
            return "paymentUnauthorized"
        case .unknown:
            return "unknown"
        }
    }
}
