//
//  Tick.swift
//  GDAXTicker
//
//  Created by Thomas Ricouard on 02/12/2017.
//  Copyright © 2017 Thomas Ricouard. All rights reserved.
//

import Foundation

struct Tick: Codable {
    let price: String
    let last_size: String?
    let time: String?
    let side: String?

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.currencyCode = "EUR"
        return formatter.string(from: NSNumber(value: Float(price)!)) ?? "Unavailable"
    }

    var formattedDate: String? {
        if let time = time {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"//this your string date format
            let date = dateFormatter.date(from: time)

            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "HH:mm:ss"
            return outputFormatter.string(from: date!)
        }
        return nil
    }
}
