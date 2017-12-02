//
//  Subscribe.swift
//  GDAXTicker
//
//  Created by Thomas Ricouard on 02/12/2017.
//  Copyright © 2017 Thomas Ricouard. All rights reserved.
//

import Foundation

struct Subscribe: Codable {
    let type = "subscribe"
    let channels: [Channel]

    init(channels: [Channel]) {
        self.channels = channels
    }
}

struct Channel: Codable {
    var name: String
    var product_ids: [String]

    init(name: String, products: [String]) {
        self.name = name
        self.product_ids = products
    }
}


