//
//  StorePaymentTransactionNotification.swift
//  StoreKitDemo
//
//  Created by 仙石 晃久 on 2020/11/24.
//

import Foundation

extension NotificationCenter {
    func postTransactionSucceeded() {
        post(name: .transactionSucceeded, object: nil)
    }
}

extension Notification.Name {
    static let transactionSucceeded = Notification.Name("paymentTransactionSucceeded")
}
