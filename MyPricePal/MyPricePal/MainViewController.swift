//
//  ViewController.swift
//  MyPricePal
//
//  Created by Brice Redmond on 4/15/19.
//  Copyright © 2019 CS48. All rights reserved.
//

import UIKit
import BarcodeScanner
import Anchors

class MainViewController: UIViewController {
//    lazy var stackView: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [scanButton, searchButton])
//        stackView.alignment = .fill
//        stackView.distribution = .fillEqually
//        stackView.spacing = 15
//        stackView.axis = .vertical
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()

    //Creates the scanButton
    var scanBarcodeButton: UIButton = {
        let scanButton = customButton(frame: .zero)
        scanButton.setTitle("Scan barcode", for: .normal)
        scanButton.addTarget(self, action: #selector(scanBarcodeAction), for: .touchUpInside)
        return scanButton
    }()
    
    //Creates the searchButton
    var searchButton: UIButton = {
        let searchButton = customButton(frame: .zero)
        searchButton.setTitle("Search", for: .normal)
        searchButton.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        return searchButton
    }()
    
    //Creates the qrCodeButton
    var qrCodeButton: UIButton = {
        let qrCodeButton = customButton(frame : .zero)
        qrCodeButton.setTitle("Scan QR code", for: .normal)
        qrCodeButton.addTarget(self, action: #selector(scanQRCodeAction), for: .touchUpInside)
        return qrCodeButton
    }()
    
    //Creates the settingsButton
    var settingsButton: UIButton = {
        let settingsButton = customButton(frame : .zero)
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsAction), for: .touchUpInside)
        return settingsButton
    }()
    
    //Called when the app opens up and lays out all of the views
    override func loadView() {
        super.loadView()
    
        //add and lays out all the views
        view.backgroundColor = .white
        
        navigationItem.title = "MyPricePal"
        navigationController?.navigationBar.barTintColor = .white
        
        addButtons()
    }
    
    func addButtons() {
        view.addSubview(scanBarcodeButton)
        view.addSubview(searchButton)
        view.addSubview(qrCodeButton)
        view.addSubview(settingsButton)
        layoutButtons()
    }
    
    func layoutButtons() {
        let guide = UILayoutGuide()
        view.addLayoutGuide(guide)
        
        //this creates the layout of the buttons, see the github for anchors for more info.
        activate(
            guide.anchor.centerX,
            guide.anchor.centerY,
            guide.anchor.size.equal.to(view.anchor.size).multiplier(3/4),
            
            searchButton.anchor.top.equal.to(guide.anchor.top),
            searchButton.anchor.trailing.leading.equal.to(guide.anchor.trailing.leading),
            searchButton.anchor.height.equal.to(guide.anchor.height).multiplier(1/4),
            
            scanBarcodeButton.anchor.top.equal.to(searchButton.anchor.bottom).constant(15),
            scanBarcodeButton.anchor.size.equal.to(searchButton.anchor.size),
            scanBarcodeButton.anchor.left.right.equal.to(searchButton.anchor.left.right),
            
            qrCodeButton.anchor.top.equal.to(scanBarcodeButton.anchor.bottom).constant(15),
            qrCodeButton.anchor.size.equal.to(searchButton.anchor.size),
            qrCodeButton.anchor.left.right.equal.to(searchButton.anchor.left.right),
            
            settingsButton.anchor.top.equal.to(qrCodeButton.anchor.bottom).constant(15),
            settingsButton.anchor.size.equal.to(searchButton.anchor.size),
            settingsButton.anchor.left.right.equal.to(searchButton.anchor.left.right)
        )
    }
    
    
    //The following objc functions are called when the buttons are clicked.
    @objc func scanBarcodeAction(sender: customButton!) {
        sender.shake()
        
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.dismissalDelegate = self
        viewController.navigationItem.title = "Scan Barcode"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func searchAction(sender: customButton!) {
        sender.shake()
        print("search requested")
    }
    
    @objc func scanQRCodeAction(sender: customButton!) {
        sender.shake()
        print("scan QR code requested")
    }
    
    @objc func settingsAction(sender: customButton!) {
        sender.shake()
        print("settings requested")
    }
}

//The following extensions make MainViewController a delegate to the barcodeviewcontroller
// and the itemviewcontroller.
extension MainViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        
        let itemViewController = ItemViewController()
        itemViewController.dismissalDelegate = self as ItemViewDismissalDelegate
        itemViewController.barcodeString = code
        
        navigationController?.pushViewController(itemViewController, animated: true)
    }
}

extension MainViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
}

extension MainViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        navigationController?.popViewController(animated: true)
    }
}

extension MainViewController: ItemViewDismissalDelegate {
    func itemViewDidDismiss(_ controller: ItemViewController) {
        navigationController?.popViewController(animated: true)
        let controller = navigationController?.topViewController as! BarcodeScannerViewController
        controller.reset(animated: true)

    }
}
