//
//  TutorialVC1.swift
//  MyPricePal
//
//  Created by Brice Redmond on 5/18/19.
//  Copyright © 2019 CS48. All rights reserved.
//

import UIKit
import Anchors

class TutorialVC1: UIViewController, UIPageViewControllerDelegate {
    
    var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        
        view.addSubview(imageView)
        
        activate(
            imageView.anchor.size.equal.to(view.anchor.size),
            imageView.anchor.center
        )
    }
}
