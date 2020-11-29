//
//  StoreDebugConstants.swift
//  StoreKitDemo
//
//  Created by 仙石 晃久 on 2020/11/23.
//

import Foundation
import StoreKit

struct StoreDebugConstants {
    static var isNetworkEnabled: Bool = true
    static var isResponseReceivabled: Bool = true

    // for view
    static var transactions: [SKPaymentTransaction] = []

    static func add(with transaction: SKPaymentTransaction) {
        transactions.append(transaction)
    }
}
