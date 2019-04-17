//
//  blackButton.swift
//  MyPricePal
//
//  Created by Brice Redmond on 4/16/19.
//  Copyright © 2019 CS48. All rights reserved.
//
import UIKit
import Anchors

@IBDesignable
class customButton: UIButton {
    override func layoutSubviews() {
        backgroundColor = .black
        setTitleColor(.white, for: .normal)
        titleLabel?.textAlignment = .center
        activate(
            (titleLabel?.anchor.top.bottom.left.right)!
        )
        translatesAutoresizingMaskIntoConstraints = false
    }
}
