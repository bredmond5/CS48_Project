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

    var firstOpen = true
    
    var barcodeViewController: BarcodeScannerViewController?
    var itemViewController: ItemViewController?
    
//    lazy var stackView: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [scanButton, searchButton])
//        stackView.alignment = .fill
//        stackView.distribution = .fillEqually
//        stackView.spacing = 15
//        stackView.axis = .vertical
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()

    var scanBarcodeButton: UIButton = {
        let scanButton = customButton(frame: .zero)
        scanButton.setTitle("Scan barcode", for: .normal)
        scanButton.addTarget(self, action: #selector(scanBarcodeAction), for: .touchUpInside)
        return scanButton
    }()
    
    var searchButton: UIButton = {
        let searchButton = customButton(frame: .zero)
        searchButton.setTitle("Search", for: .normal)
        searchButton.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        return searchButton
    }()
    
    var qrCodeButton: UIButton = {
        let qrCodeButton = customButton(frame : .zero)
        qrCodeButton.setTitle("Scan QR code", for: .normal)
        qrCodeButton.addTarget(self, action: #selector(scanQRCodeAction), for: .touchUpInside)
        return qrCodeButton
    }()
    
    var settingsButton: UIButton = {
        let settingsButton = customButton(frame : .zero)
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsAction), for: .touchUpInside)
        return settingsButton
    }()
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        navigationItem.title = "MyPricePal"
        navigationController?.navigationBar.barTintColor = .white
    
        view.addSubview(scanBarcodeButton)
        view.addSubview(searchButton)
        view.addSubview(qrCodeButton)
        view.addSubview(settingsButton)
        let guide = UILayoutGuide()
        view.addLayoutGuide(guide)
        
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
        
        barcodeViewController = BarcodeScannerViewController()
        barcodeViewController?.codeDelegate = self as BarcodeScannerCodeDelegate
        barcodeViewController?.errorDelegate = self as BarcodeScannerErrorDelegate
        barcodeViewController?.dismissalDelegate = self as BarcodeScannerDismissalDelegate
        
        itemViewController = ItemViewController()
        itemViewController?.dismissalDelegate = self as ItemViewDismissalDelegate
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstOpen {
            present(barcodeViewController ?? self, animated: true, completion: nil)
            firstOpen = false
        }
    }
    
    @objc func scanBarcodeAction(sender: customButton!) {
        sender.shake()
        present(barcodeViewController ?? self, animated: true, completion: nil)
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

extension MainViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print(code)
        controller.reset()
        controller.dismiss(animated: true, completion: nil)
        itemViewController?.barcodeString = code
        present(itemViewController ?? self, animated: true, completion: nil)
    }
}

extension MainViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
}

extension MainViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
        firstOpen = false
    }
}

extension MainViewController: ItemViewDismissalDelegate {
    func itemViewDidDismiss(_ controller: ItemViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
