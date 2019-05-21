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
    
    //var imageView = UIImageView()
    let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        
        view.addSubview(imageView)
        
        if #available(iOS 11.0, *) {
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
        
        if #available(iOS 11.0, *) {
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
        
        let width: CGFloat = 60
        
        imageView.heightAnchor.constraint(equalToConstant : width).isActive = true
        
        activate(
            imageView.anchor.size.equal.to(view.anchor.size),
            imageView.anchor.center
        )
    }
}
