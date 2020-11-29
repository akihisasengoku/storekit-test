//
//  PurchasedViewController.swift
//  StoreKitDemo
//
//  Created by 仙石 晃久 on 2020/11/23.
//

import UIKit

class PurchasedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension PurchasedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        StoreDebugConstants.transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transaction = StoreDebugConstants.transactions[indexPath.row]
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = transaction.payment.productIdentifier
        let detail = "id: \(transaction.transactionIdentifier!), date: \(DateFormatter.short(transaction.transactionDate!))"
        cell.detailTextLabel?.text = detail
        return cell
    }
}

extension DateFormatter {
    class func short(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}
