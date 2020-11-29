//
//  ViewController.swift
//  StoreKitDemo
//
//  Created by 仙石 晃久 on 2020/11/23.
//

import UIKit
import StoreKit

class ViewController: UIViewController {

    enum Section: String, CaseIterable {
        case product
        case network
        case response
        case state
        case actions

        var value: String? {
            switch self {
            case .network:
                return StoreDebugConstants.isNetworkEnabled.description
            case .response:
                return StoreDebugConstants.isResponseReceivabled.description
            case .actions:
                return "resumeUnfinishedTransactions"
            case .product, .state:
                return ""
            }
        }

        enum State: String, CaseIterable {
            case transactionState
            case transactionCount
        }
    }

    var products: [SKProduct] = []
    var purchaseState: StorePaymentTransactionState?
    let productsRequest = StoreProductsRequest()
    let paymentManager = StorePaymentManager.shared

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "demo"

        let purchasedbarButton = UIBarButtonItem(title: "Purchased", style: .done, target: self, action: #selector(showPurchased))
        navigationItem.rightBarButtonItem = purchasedbarButton

        fetchProducts()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(succeededPaymentTransaction),
            name: .transactionSucceeded,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        paymentManager.resumeUnfinishedTransactions()
        tableView.reloadData()
    }

    @objc func showPurchased() {
        let vc = PurchasedViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func succeededPaymentTransaction() {
        tableView.reloadData()
    }
}

extension ViewController {
    func fetchProducts() {
        let productIdentifiers = [
            "com.ameba.consumable1",
            "com.ameba.consumable2",
            "com.ameba.consumable3"
        ]

        productsRequest.fetchProducts(identifiers: productIdentifiers) { [weak self] response in
            DispatchQueue.main.async {
                switch response {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let data):
                    self?.products = data.products
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

extension ViewController {
    func purchase(product: SKProduct) {
        paymentManager.purchase(product: product) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self?.present(alert, animated: true, completion: nil)

            case .success(let state):
                self?.purchaseState = state
                self?.tableView.reloadData()
                
            }
        }
    }
}

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Section.allCases[section]
        switch section {
        case .product:
            return products.count
        case .state:
            return Section.State.allCases.count
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = Section.allCases[section]
        return section.rawValue
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section.allCases[indexPath.section]
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
        
        switch section {
        case .product:
            let product = products[indexPath.row]
            cell.textLabel?.text = product.localizedTitle
            cell.detailTextLabel?.text = product.priceString
        case .state:
            let state = Section.State.allCases[indexPath.row]
            switch state {
            case .transactionState:
                cell.textLabel?.text = "transactionState: " + (purchaseState?.localizedDescription ?? "init")
            case .transactionCount:
                cell.textLabel?.text = "transactionCount: " + String(SKPaymentQueue.default().transactions.count)
            }
        default:
            cell.textLabel?.text = section.value
        }

        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = Section.allCases[indexPath.section]
        switch section {
        case .product:
            let product = products[indexPath.row]
            purchase(product: product)
        case .network:
            StoreDebugConstants.isNetworkEnabled.toggle()
            tableView.reloadData()
        case .response:
            StoreDebugConstants.isResponseReceivabled.toggle()
            tableView.reloadData()
        case .actions:
            paymentManager.resumeUnfinishedTransactions()
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SKProduct {
    var priceString: String? {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}
