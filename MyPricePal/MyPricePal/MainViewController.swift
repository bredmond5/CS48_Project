//
//  ViewController.swift
//  MyPricePal
//
//  Created by Brice Redmond on 4/15/19.
//  Copyright © 2019 CS48. All rights reserved.
//

import UIKit
import BarcodeScanner
import FirebaseDatabase

class MainViewController: UIViewController{

    var firstOpen = true
    var ref: DatabaseReference!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpViewController()
        ref = Database.database().reference()
        if firstOpen {
            setUpScanner()
        }
    }
    
    func setUpScanner() {
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self as BarcodeScannerCodeDelegate
        viewController.errorDelegate = self as BarcodeScannerErrorDelegate
        viewController.dismissalDelegate = self as BarcodeScannerDismissalDelegate
        
        present(viewController, animated: true, completion: nil)
    }
    
    func setUpViewController() {
        view.backgroundColor = .white
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.backgroundColor = .black
        button.setTitle("Scan", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.center = view.center
        
        self.view.addSubview(button)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        setUpScanner()
    }
}

extension MainViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print(code)
        controller.reset()
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

