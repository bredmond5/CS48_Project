//
//  ItemViewController.swift
//  MyPricePal
//
//  Created by Brice Redmond on 4/19/19.
//  Copyright © 2019 CS48. All rights reserved.
//

import UIKit
import Anchors

public protocol ItemViewDismissalDelegate : class {
    func itemViewDidDismiss(_ controller: ItemViewController)
}

open class ItemViewController: UIViewController {

    public weak var dismissalDelegate: ItemViewDismissalDelegate?
    
    public var barcodeString: String? //Barcode string to send to firebase
    
    var backButton: UIBarButtonItem = {
        let button = UIButton(frame: .zero)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(dismissalAction), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        return barButton
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Lays Potato Chips"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .black
        label.sizeToFit()
        return label
    }()
    
    var navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.isTranslucent = false
        navigationBar.backgroundColor = .white
        return navigationBar
    }()
    
    @objc func dismissalAction(sender: UIButton!) {
       dismissalDelegate?.itemViewDidDismiss(self)
    }
    
    override open func loadView() {
        super.loadView()
        view.backgroundColor = .white
        addNavigationBar()
        layoutViews()
    }
    
    func addNavigationBar() {
        navigationItem.leftBarButtonItem = backButton
        navigationItem.titleView = titleLabel
        
        navigationBar.items = [navigationItem]
        view.addSubview(navigationBar)

    }
    
    func layoutViews() {
        
        let textView = UITextView(frame: .zero)
        textView.text = barcodeString
        textView.textColor = .black
        textView.font = UIFont.boldSystemFont(ofSize: 25)
        textView.textAlignment = .center
        //Activates the layout between the UIs.
        
        view.addSubview(textView)
        
        activate(
            navigationBar.anchor.left.right.equal.to(view.anchor.left.right),
            navigationBar.anchor.top.equal.to(view.safeAreaLayoutGuide.anchor.top),
            
            textView.anchor.center.equal.to(view.safeAreaLayoutGuide.anchor.center),
            textView.anchor.width.equal.to(view.anchor.width).multiplier(3/5),
            textView.anchor.height.equal.to(textView.anchor.width).multiplier(1/2)
            
        )
    }
}
