//
//  PersistenceService.swift
//  StoreKitDemo
//
//  Created by 仙石 晃久 on 2020/11/23.
//

import StoreKit

struct Persistence {
    static var transactions: [SKPaymentTransaction] = []

    static func add(with transaction: SKPaymentTransaction) {
        transactions.append(transaction)
    }
}

