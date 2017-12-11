//
//  TickTableViewCell.swift
//  GDAXTicker
//
//  Created by Thomas Ricouard on 02/12/2017.
//  Copyright © 2017 Thomas Ricouard. All rights reserved.
//

import UIKit
import UI
import GDAX_Swift

class TickTableViewCell: UITableViewCell {

    static let id = "TickTableViewCell"

    @IBOutlet var sizeLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var typeView: UIView!

    var tick: TickerResponse! {
        didSet {
            typeView.backgroundColor = tick.side == "buy" ? UIColor.gd_greenColor : UIColor.gd_redColor
            sizeLabel.text = tick.last_size ?? "0"
            valueLabel.text = tick.formattedPrice
            dateLabel.text = tick.formattedDate ?? "0"
        }
    }
}
