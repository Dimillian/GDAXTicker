//
//  Subscribe.swift
//  GDAXTicker
//
//  Created by Thomas Ricouard on 02/12/2017.
//  Copyright © 2017 Thomas Ricouard. All rights reserved.
//

import Foundation

public struct Subscribe: Codable {
    public let type = "subscribe"
    public let channels: [Channel]

    public init(channels: [Channel]) {
        self.channels = channels
    }
}

public struct Channel: Codable {
    public var name: String
    public var product_ids: [String]

    public init(name: String, products: [String]) {
        self.name = name
        self.product_ids = products
    }
}


