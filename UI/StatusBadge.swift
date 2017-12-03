//
//  StatusBadge.swift
//  UI
//
//  Created by Thomas Ricouard on 03/12/2017.
//  Copyright © 2017 Thomas Ricouard. All rights reserved.
//

import UIKit

@IBDesignable
open class StatusBadge: UIView {

    private let label = UILabel()

    @IBInspectable public var title: String = "" {
        didSet {
            label.text = title
        }
    }

    open override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        setup()
    }

    func setup() {

        layer.masksToBounds = true
        layer.cornerRadius = 15

        addSubview(label)

        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        label.frame = bounds
    }
    
}
