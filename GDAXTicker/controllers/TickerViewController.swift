//
//  TickerViewController.swift
//  GDAXTicker
//
//  Created by Thomas Ricouard on 02/12/2017.
//  Copyright © 2017 Thomas Ricouard. All rights reserved.
//

import UIKit

class TickerViewController: UIViewController {
    let networkSocket = NetworkSocket()
    var datasource: [Tick] = []

    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.statusBarStyle = .lightContent
        title = "Loading..."

        let nib = UINib(nibName: TickTableViewCell.id, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: TickTableViewCell.id)

        networkSocket.onTick = {tick in
            self.title = tick.formattedPrice
            self.datasource.insert(tick, at: 0)
            self.tableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .automatic)
        }

        networkSocket.start()
        let channel = Channel(name: "ticker", products: ["LTC-EUR"])
        let subscription = Subscribe(channels: [channel])
        networkSocket.subscribe(subscription: subscription)
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
