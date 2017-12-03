//
//  TickerViewController.swift
//  GDAXTicker
//
//  Created by Thomas Ricouard on 02/12/2017.
//  Copyright © 2017 Thomas Ricouard. All rights reserved.
//

import UIKit
import UI

class TickerViewController: UIViewController {
    let networkSocket = NetworkSocket()
    var datasource: [Tick] = []

    @IBOutlet var tableView: UITableView!
    @IBOutlet var statusBadge: StatusBadge!

    var currentCurrency = "LTC-EUR" {
        didSet {
            networkSocket.onDisconnect = {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.reconnect()
                })
            }
            networkSocket.stop()
        }
    }

    let currencies = ["LTC-USD", "LTC-EUR", "BTC-USD", "BTC-EUR"]

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.statusBarStyle = .lightContent
        title = currentCurrency

        statusBadge.backgroundColor = .gd_redColor
        statusBadge.title = "Loading..."

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onStatusView))
        statusBadge.isUserInteractionEnabled = true
        statusBadge.addGestureRecognizer(tapGesture)

        let nib = UINib(nibName: TickTableViewCell.id, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: TickTableViewCell.id)

        reconnect()
    }

    func reconnect() {
        datasource = []
        tableView.reloadData()

        networkSocket.onTick = {tick in
            self.title = "\(self.currentCurrency): \(tick.formattedPrice)"
            self.datasource.insert(tick, at: 0)
            self.tableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .automatic)
        }

        networkSocket.onConnectionChange = {isConnected in
            if !isConnected {
                self.statusBadge.backgroundColor = .gd_redColor
                self.statusBadge.title = "Disconnected"
            } else {
                self.statusBadge.backgroundColor = .gd_greenColor
                self.statusBadge.title = "Connected"
            }
        }

        networkSocket.start()
        let channel = Channel(name: "ticker", products: [currentCurrency])
        let subscription = Subscribe(channels: [channel])
        networkSocket.subscribe(subscription: subscription)
    }

    @objc func onStatusView() {
        networkSocket.isConnected ? networkSocket.stop() : reconnect()
    }
    
    @IBAction func onCurrencyButton(_ sender: Any) {
        let sheet = UIAlertController(title: "Choose network", message: nil, preferredStyle: .actionSheet)
        for currency in currencies {
            sheet.addAction(UIAlertAction(title: currency, style: .default, handler: { (_) in
                self.currentCurrency = currency
            }))
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(sheet, animated: true, completion: nil)
    }
}

extension TickerViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TickTableViewCell.id, for: indexPath) as! TickTableViewCell
        cell.tick = datasource[indexPath.row]
        return cell
    }
}
