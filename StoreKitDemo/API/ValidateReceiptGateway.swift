//
//  ValidateReceiptsGateway.swift
//  StoreKitDemo
//
//  Created by 仙石 晃久 on 2020/11/23.
//

import Foundation
import StoreKit

// レシートの検証を行う擬似クラス
final class ValidateReceiptGateway {
    func validate(transaction: SKPaymentTransaction, completion: @escaping (Result<Void, StorePaymentError>)->()) {
        guard StoreDebugConstants.isNetworkEnabled else {
            // レシート送信に失敗するケース
            completion(.failure(StorePaymentError.sendReceiptError))
            return
        }

        // 3. レシート送信 (擬似的) APIClient.send()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // failed
            guard StoreDebugConstants.isResponseReceivabled else {
                completion(.failure(StorePaymentError.receiveResponseError))
                return
            }

            // success
            completion(.success(()))

            // 状態管理用
            Persistence.add(with: transaction)
            NotificationCenter.default.postTransactionSucceeded()
        }
    }
}
