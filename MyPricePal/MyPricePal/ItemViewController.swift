//
//  ItemViewController.swift
//  MyPricePal
//
//  Created by Brice Redmond on 4/19/19.
//  Copyright © 2019 CS48. All rights reserved.
//

import UIKit
import Anchors
import FirebaseDatabase

public protocol ItemViewDismissalDelegate : class {
    func itemViewDidDismiss(_ controller: ItemViewController)
}

public class ItemViewController: UIViewController {

    public weak var dismissalDelegate: ItemViewDismissalDelegate?
    public let textView = UITextView(frame: .zero)
    public var barcodeString: String? //Barcode string to send to firebase
    public var itemN: String?
    
    func getItemName(){
        let ref = Database.database().reference().child("Barcodes")
        ref.child(barcodeString!).observeSingleEvent(of: .value, with: {(snapShot) in
            if let val = snapShot.value as? String{
                self.textView.text = val
                self.itemN = val
                self.showAlertButtonTapped()
            }
            else{
                print("could not execute")
            }
    })
}
    

    
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
    
    @objc func dismissalAction(sender: Any) {
        dismissalDelegate?.itemViewDidDismiss(self)
    }
    
    override open func loadView() {
        super.loadView()
        getItemName()
        view.backgroundColor = .white
        navigationItem.titleView = titleLabel
        let backBarButton = UIBarButtonItem(title: "Scan", style: .plain, target: self, action: #selector(dismissalAction(sender:)))        
        navigationItem.leftBarButtonItem = backBarButton
        layoutViews()
    }
    func showAlertButtonTapped(){
        let alert = UIAlertController(title: "Item", message: "Is " + itemN! + " your item?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func layoutViews() {
        
        textView.textColor = .black
        textView.font = UIFont.boldSystemFont(ofSize: 25)
        textView.textAlignment = .center
        view.addSubview(textView)
        
//        let alertButton = UIButton(frame: .zero);
//        alertButton.addTarget(self, action: #selector(showAlertButtonTapped(_:)), for: .touchUpInside)
        
        activate(
            textView.anchor.center.equal.to(view.safeAreaLayoutGuide.anchor.center),
            textView.anchor.width.equal.to(view.anchor.width).multiplier(3/5),
            textView.anchor.height.equal.to(textView.anchor.width).multiplier(1/2)
            

        )
    }
}
