//
//  AccountViewController.swift
//  GDAXTicker
//
//  Created by Alexandre Barbier on 08/12/2017.
//  Copyright © 2017 Thomas Ricouard. All rights reserved.
//

import UIKit
import GDAX_Swift
import UserNotifications

class AccountTableVIewCell: UITableViewCell {

    @IBOutlet var accountNameLabel: UILabel!
    @IBOutlet var currentPriceLabel: UILabel!
    var sub:Subscription?
    var account: Account! {
        didSet {
            accountNameLabel.text = account.currency
            sub?.unsubscribe()
            sub = GDAX.feed.subscribeTicker(for: [gdax_value(from: gdax_products(rawValue: account.currency!)!, to: .EUR)]) { (tick) in
                DispatchQueue.main.async {
                    self.currentPriceLabel.text = "\(String(format: "%0.2f", Float(tick.price!)!))"
                    UIView.animate(withDuration: 0.1, animations: {
                        self.backgroundColor = tick.side == "buy" ? UIColor.green.withAlphaComponent(0.5) : UIColor.red.withAlphaComponent(0.5)
                    }, completion: { (finish) in
                        if finish {
                            UIView.animate(withDuration: 0.1, animations: {
                                self.backgroundColor = .white
                            }, completion: { (finish) in
                                if finish {

                                }
                            })
                        }
                    })
                }
            }
        }
    }
}

class AccountViewController: UIViewController {

    @IBOutlet var moneyLabel: UILabel!
    @IBOutlet var tableview: UITableView!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var gainLabel: UILabel!

    var isConnected = false
    var accountSubscription: Subscription?

    var gain: String = "" {
        didSet {
            moneyLabel.text = gain
        }
    }
    var capitalGain:[String: Float] = [:]
    var orders:[String: [OrderResponse]] = [:] {
        didSet {
            for (key, value) in orders {
                var total:Float = 0
                for order in value {
                    if order.side == "buy" {
                        total -= Float(order.price!)! * Float(order.size!)!
                    } else {
                        total += Float(order.price!)! * Float(order.size!)!
                    }
                }
                capitalGain[key] = total
            }
        }
    }

    var accounts:[String: Account] = [:]
    var datasource:[Account] = [] {
        didSet{
            let products: [gdax_value] = accounts.map { source in
                return gdax_value(from: gdax_products(rawValue: source.value.currency!)!, to: .EUR)
            }

            accountSubscription = GDAX.feed.subscribeTicker(for: products) { (tick) in
                if let index = self.tableview.indexPathForSelectedRow {
                    let currency = self.datasource[index.row].currency!
                    if tick.product_id == "\(currency)-EUR" {
                        DispatchQueue.main.async {
                            let p = tick.floatPrice! * Float(self.accounts[currency]!.balance!)!
                            self.gain = "\(String(format:"%0.2f", Float(p))) EUR"
                            if self.capitalGain[tick.product_id!] != nil {
                                self.gainLabel.text = "\(self.capitalGain[tick.product_id!]! + p)"
                            }
                            self.balanceLabel.text = "for \(String(format:"%0.6f", Float(self.accounts[currency]!.hold!)!)) \(currency)"
                        }
                    }
                }
                else {
                    if tick.product_id == "LTC-EUR" {
                        DispatchQueue.main.async {
                            let p = tick.floatPrice! * Float(self.accounts["LTC"]!.balance!)!
                            self.gain = "\(String(format:"%0.2f", p)) EUR"
                            if self.capitalGain["LTC-EUR"] != nil {
                                self.gainLabel.text = "\(self.capitalGain["LTC-EUR"]! + p)"
                            }
                            self.balanceLabel.text = "for \(String(format:"%0.6f", Float(self.accounts["LTC"]!.balance!)!)) Ltc"
                        }
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "account"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard GDAX.isAuthenticated else {
            GDAX.askForAuthentication(inVC: self, completion: { granted in
                if granted {
                    self.connect()
                }
            })
            return
        }
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [UNAuthorizationOptions.badge, UNAuthorizationOptions.sound, UNAuthorizationOptions.alert]) { (granted, error) in

        }
        connect()
    }

    func connect() {
        !self.isConnected ?
            GDAX.authenticate.getAccounts { (accounts, error) in
                guard let accounts = accounts, error == nil else {
                    return
                }
                self.isConnected = true

                for account in accounts {
                    self.accounts.updateValue(account, forKey: account.currency!)
                    GDAX.authenticate.getOrders(status: "done", product_id: "\(account.currency!)-EUR" ,completion: { (orders, error) in
                        self.orders.updateValue(orders ?? [], forKey: "\(account.currency!)-EUR")
                    })
                }
                self.datasource = accounts
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                }
            } : ()
    }
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "AccountCellIdentifier") as? AccountTableVIewCell
        cell?.account = datasource[indexPath.row]
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = self.datasource[indexPath.row].currency!
        GDAX.market.product(productId: "\(currency)-EUR").getLastTick { (tick, error) in
            DispatchQueue.main.async {
                let p = Float(tick!.price!)! * Float(self.accounts[currency]!.balance!)!
                self.gain = "\(String(format:"%0.2f", Float(p))) EUR"
                if self.capitalGain["\(currency)-EUR"] != nil {
                    self.gainLabel.text = "\(self.capitalGain["\(currency)-EUR"]! + p)"
                }
                self.balanceLabel.text = "for \(String(format:"%0.6f", Float(self.accounts[currency]!.hold!)!)) \(currency)"
            }
        }
    }
}
