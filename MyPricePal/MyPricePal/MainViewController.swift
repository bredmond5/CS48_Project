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
    
//    lazy var stackView: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [scanButton, searchButton])
//        stackView.alignment = .fill
//        stackView.distribution = .fillEqually
//        stackView.spacing = 15
//        stackView.axis = .vertical
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()

    var scanButton: UIButton = {
        let scanButton = customButton(frame: .zero)
        scanButton.setTitle("Scan", for: .normal)
        scanButton.addTarget(self, action: #selector(scanAction), for: .touchUpInside)
        return scanButton
    }()
    
    var searchButton: UIButton = {
        let searchButton = customButton(frame: .zero)
        searchButton.setTitle("Search", for: .normal)
        searchButton.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        return searchButton
    }()
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        navigationItem.title = "MyPricePal"
        navigationController?.navigationBar.barTintColor = .white
    
        view.addSubview(scanButton)
        view.addSubview(searchButton)
        
        activate(
            searchButton.anchor.top.constant(150),
            searchButton.anchor.paddingHorizontally(100),
            searchButton.anchor.height.equal.to(searchButton.anchor.width).multiplier(1/2),
            scanButton.anchor.top.equal.to(searchButton.anchor.bottom).constant(15),
            scanButton.anchor.size.equal.to(searchButton.anchor.size),
            searchButton.anchor.left.right.equal.to(scanButton.anchor.left.right)
            
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
    @objc func scanAction(sender: UIButton!) {
        setUpScanner()
    }
    
    @objc func searchAction(sender: UIButton!) {
        print("search requested")
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

