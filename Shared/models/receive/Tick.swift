//
//  Tick.swift
//  GDAXTicker
//
//  Created by Thomas Ricouard on 02/12/2017.
//  Copyright © 2017 Thomas Ricouard. All rights reserved.
//

import Foundation

public struct Tick: Codable {
    public let price: String
    public let last_size: String?
    public let time: String?
    public let side: String?
    public let product_id: String?

    public var floatPrice: Float? {
        return Float(price)
    }

    public var formattedPrice: String {
        return currentPriceFormatter.string(from: NSNumber(value: Float(price)!)) ?? "Unavailable"
    }

    public var currentPriceFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.currencyCode = product_id != nil && product_id!.contains("USD") ? "USD" : "EUR"
        return formatter
    }

    public var formattedDate: String? {
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
