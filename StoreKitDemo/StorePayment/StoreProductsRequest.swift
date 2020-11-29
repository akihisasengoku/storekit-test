//
//  StoreProductsGateway.swift
//  StoreKitDemo
//
//  Created by 仙石 晃久 on 2020/11/23.
//

import StoreKit

protocol StoreProductsRequestProtocol: AnyObject {
    func fetchProducts(identifiers: [String], completion: @escaping (Result<SKProductsResponse, Error>) -> Void)
    func cancel()
}

final class StoreProductsRequest: NSObject, StoreProductsRequestProtocol {
    /// - Note: Be sure to keep a strong reference to the request object
    /// - SeeAlso: https://developer.apple.com/documentation/storekit/skproductsrequest
    private var request: SKProductsRequest?
    private var completion: ((Result<SKProductsResponse, Error>) -> Void)?

    func fetchProducts(identifiers: [String], completion: @escaping (Result<SKProductsResponse, Error>) -> Void) {
        self.completion = completion
        self.request = SKProductsRequest(productIdentifiers: Set(identifiers))
        request?.delegate = self
        request?.start()
    }

    func cancel() {
        completion = nil
    }
}

// MARK: - SKProductsRequestDelegate
extension StoreProductsRequest: SKProductsRequestDelegate {
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
