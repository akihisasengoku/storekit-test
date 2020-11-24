//
//  StoreProductsGateway.swift
//  StoreKitDemo
//
//  Created by 仙石 晃久 on 2020/11/23.
//

import StoreKit

protocol StoreProductsGatewayProtocol: AnyObject {

}

final class StoreProductsGateway: NSObject, StoreProductsGatewayProtocol {

    private var completion: ((Result<SKProductsResponse, Error>) -> (Void))?

    func fetchProducts(completion: ((Result<SKProductsResponse, Error>) -> (Void))?) {

        self.completion = completion

        let productIdentifiers: Set<String> = [
            "com.ameba.consumable1",
            "com.ameba.consumable2",
            "com.ameba.consumable3"
        ]

        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }

    func cancel() {
        completion = nil
    }
}

// MARK: - SKProductsRequestDelegate

extension StoreProductsGateway: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        completion?(.success(response))
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        completion?(.failure(error))
    }

    func requestDidFinish(_ request: SKRequest) {
        completion = nil
    }
}
