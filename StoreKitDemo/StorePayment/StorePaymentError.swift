//
//  StorePaymentError.swift
//  StoreKitDemo
//
//  Created by 仙石 晃久 on 2020/11/23.
//

enum StorePaymentError: Error {
    case notFoundItem
    case validateReceiptFailed(Error)
    case hasUnfinishedTransaction
    case appStoreTransactionFailed(Error)
    case paymentUnauthorized
    case unknown
}
