//
//  UserDefault.swift
//  GDAXTicker
//
//  Created by Thomas Ricouard on 03/12/2017.
//  Copyright © 2017 Thomas Ricouard. All rights reserved.
//

import Foundation

extension UserDefaults {
    public var vaults: [String: Float]? {
        get {
            return UserDefaults.standard.value(forKey: "vaults") as? [String: Float]
        }
        set {
            UserDefaults.standard.set(newValue!, forKey: "vaults")
            UserDefaults.standard.synchronize()
        }
    }
}
