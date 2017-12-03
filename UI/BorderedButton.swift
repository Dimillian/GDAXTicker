//
//  BorderedButton.swift
//  UI
//
//  Created by Thomas Ricouard on 03/12/2017.
//  Copyright © 2017 Thomas Ricouard. All rights reserved.
//

import UIKit

@IBDesignable
open class BorderedButton: UIButton {

    override open func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        setup()
    }

    func setup() {
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 0.5
        layer.masksToBounds = false
        layer.cornerRadius = 5
    }

}
