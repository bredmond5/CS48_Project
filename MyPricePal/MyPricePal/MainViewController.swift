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
import FirebaseDatabase
import AVFoundation

class MainViewController: UIViewController {
    
    var searchVC: SearchViewController?
    var itemVC: ItemViewController?
    
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
        
        searchVC = SearchViewController()
        searchVC?.dismissalDelegate = self
        searchVC?.searchRequestedDelegate = self
        
        itemVC = ItemViewController()
        itemVC?.dismissalDelegate = self
        
        
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
        
        let barcodeVC = BarcodeScannerViewController()
        barcodeVC.codeDelegate = self
        barcodeVC.errorDelegate = self
        barcodeVC.dismissalDelegate = self
        barcodeVC.navigationItem.title = "Scan Barcode"
        barcodeVC.isOneTimeSearch = true
        barcodeVC.cameraViewController.showsCameraButton = true
    
  //      barcodeVC.metadata.append(AVMetadataObject.ObjectType.qr)

        navigationController?.pushViewController(barcodeVC, animated: true)
    }
    
    @objc func searchAction(sender: customButton!) {
        sender.shake()
        navigationController?.pushViewController(searchVC!, animated: true)
    }
    
    @objc func scanQRCodeAction(sender: customButton!) {
        sender.shake()
        print("scan QR code requested")
    }
    
    @objc func settingsAction(sender: customButton!) {
        sender.shake()
        print("settings requested")
    }
    
    func getItemName(_ barcodeString: String,  _ barcodeVC: BarcodeScannerViewController){
        let ref = Database.database().reference().child("Barcodes")
        ref.child(barcodeString).observeSingleEvent(of: .value, with: {(snapShot) in
            if let val = snapShot.value as? String{
                self.showAlertButtonTapped(val, barcodeVC)
            }
            else{
                self.alertButtonError(barcode: barcodeString, barcodeVC)
            }
        })
    }
    
    func alertButtonError(barcode: String, _ barcodeVC: BarcodeScannerViewController) {
        let alert = UIAlertController(title: "Error", message: "Could not find " + barcode, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default, handler: {action in
            barcodeVC.reset()
        }))
        
        barcodeVC.present(alert, animated: true)
    }
    
    func showAlertButtonTapped(_ itemN: String, _ barcodeVC: BarcodeScannerViewController){
        let alert = UIAlertController(title: "Item", message: "Is " + itemN + " your item?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {action in
            self.searchVC?.giveItemScanned(itemN)
            self.itemVC?.itemN = itemN
            let backBarButton = UIBarButtonItem(title: "Scan", style: .plain, target: self, action: #selector(dismissalAction(sender:)))
            navigationItem.leftBarButtonItem = backBarButton
            self.navigationController?.pushViewController(self.itemVC!, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: {action in
            barcodeVC.reset(animated: true)
        }))
        barcodeVC.present(alert, animated: true)
    }
}

//The following extensions make MainViewController a delegate to the barcodeviewcontroller
// and the itemviewcontroller and searchviewcontroller.
extension MainViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        getItemName(code, controller)
    }
}

extension MainViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        controller.resetWithError(message: error.localizedDescription)
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
        
        if navigationController?.topViewController is BarcodeScannerViewController
        {
            let barcodeVC = navigationController?.topViewController as! BarcodeScannerViewController
            barcodeVC.reset(animated: true)
        }
        
    }
}

extension MainViewController: SearchViewControllerDismissalDelegate {
    func searchViewDidDismiss(_ controller: SearchViewController) {
        navigationController?.popViewController(animated: true)
    }
}

extension MainViewController: SearchRequestedDelegate {
    func searchRequested(_ item: String) {
        itemVC?.itemN = item
        navigationController?.pushViewController(itemVC!, animated: true)
    }
}
