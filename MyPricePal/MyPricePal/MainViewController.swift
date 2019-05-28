//
//  MainViewController.swift
//  MyPricePal
//
//  Created by Brice Redmond on 4/15/19.
//  Copyright © 2019 CS48. All rights reserved.
//

import UIKit
import BarcodeScanner
import Anchors
import FirebaseDatabase
import Foundation
import AVFoundation
import SafariServices

//The MainViewController handles switching between the other view controllers. It does
//not have any views of its own as it is a UINavigationController.
class MainViewController: UINavigationController {
    
    //The controller where all the barcodes searched will show up
    var searchVC: SearchViewController?
    
    //The controller that displays item prices and deals
    var itemVC: ItemViewController?
    
    //The controller that handles scanning the barcode.
    var barcodeVC: BarcodeScannerViewController?
    
    var curPriceFinder: PriceFinder?
    var curKeywordFinder: KeywordFinder?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //Here we set up all of the view controllers and their delegates.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Initialize searchVC and set the delegates.
        searchVC = SearchViewController()
        searchVC?.searchRequestedDelegate = self
        
        //initialize barcodeVC and send delegates.
        let barcodeVC = topViewController as! BarcodeScannerViewController
        barcodeVC.codeDelegate = self
        barcodeVC.errorDelegate = self
        barcodeVC.dismissalDelegate = self
        barcodeVC.navigationItem.title = "Scan Barcode" //Set the title of the BarcodeVC
        barcodeVC.isOneTimeSearch = true //So that the barcodeScanner doesnt keep scanning
        barcodeVC.messageViewController.view.backgroundColor = .black
        barcodeVC.messageViewController.textLabel.superview?.backgroundColor = .black
        barcodeVC.messageViewController.imageView.backgroundColor = .white
        barcodeVC.messageViewController.textLabel.textColor = .white
        barcodeVC.messageViewController.borderView.layer.borderColor = UIColor.white.cgColor

        barcodeVC.cameraViewController.showsCameraButton = true //for front facing camera
        
        //Give the barcodeVC the search button
        setBarcodeVCButtons(barcodeVC)
        
    }
    
    func getItemName(_ barcodeString: String,  _ barcodeVC: BarcodeScannerViewController){
        
        let ref = Database.database().reference().child("Barcodes")
    
        ref.child(barcodeString).observeSingleEvent(of: .value, with: {(snapShot) in
            if let val = snapShot.value as? String{
                self.setVCs(val, barcodeString)
                self.setKeywordFinder(val)
            }else{
                let urlBase = "https://api.upcitemdb.com/prod/trial/lookup?upc=" //barcodeString and urlBase combine to create the url
                let url = URL(string: urlBase + barcodeString)!
                let task = URLSession.shared.dataTask(with: url){(data, resp, error) in //Creates the url connection to the API
                    guard let data = data else{
                        print("data was nil")
                        return
                    }
                    guard let htmlString = String(data: data, encoding: String.Encoding.utf8)else{//Saves the html with the JSON into a string
                        print("cannot cast data into string")
                        return
                        
                    }
                    let leftSideOfTheValue = """
            title":"
            """
                    //Left side before the desired value in the JSON portion of the HTML
                    let rightSideOfTheValue = """
            ","description
            """
                    //right side after the desired value in the JSON portion of the HTML
                    guard let leftRange = htmlString.range(of: leftSideOfTheValue)else{
                        self.alertButtonError(barcodeString, barcodeVC)
                        print("cannot find left range")
                        return
                    }//Creates left side range
                    guard let rightRange = htmlString.range(of: rightSideOfTheValue)else{
                        print("cannot find right range")
                        return
                    }//Creates right side range
                    let rangeOfTheValue = leftRange.upperBound..<rightRange.lowerBound //Appends the ranges together
                 //   self.showAlertButtonTapped(String(htmlString[rangeOfTheValue]), barcodeString,barcodeVC) //Displays the product name
                    
                    let itemN = String(htmlString[rangeOfTheValue])
                    self.setVCs(itemN, barcodeString)
                    self.setKeywordFinder(itemN)
                    
                    let ref2 = Database.database().reference()
                    ref2.child("Barcodes").child(barcodeString).setValue(String(htmlString[rangeOfTheValue]))
                }
                
                task.resume()
            }
        })
    }



    //Asks the user if the item is correct, and if so goes to the itemVC. If not goes back to scanning
    func showAlertButtonTapped(_ itemN: String, _ barcodeNum: String, _ barcodeVC: BarcodeScannerViewController){
        if topViewController is BarcodeScannerViewController {
            let alert = UIAlertController(title: "Item", message: "Is " + itemN + " your item?", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {action in
                
                self.pushViewController(self.itemVC!, animated: true)
               
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: {action in
                self.resetBarcodeVC(barcodeVC)
            
            }))
            
            barcodeVC.present(alert, animated: true)
        }
        
        else{
            self.pushViewController(self.itemVC!, animated: true)
        }
    }
        

        
        //Shows that the firebase could not find the barcodestring and sends the user back to scanning
    func alertButtonError(_ barcodeNum: String, _ barcodeVC: BarcodeScannerViewController) {
        let alert = UIAlertController(title: "Error", message: "Could not find " + barcodeNum, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Enter Item Yourself", style: UIAlertAction.Style.default, handler: {action in
            self.alertAddItem(barcodeNum, barcodeVC)
        }))
        
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default, handler: {action in
            self.resetBarcodeVC(barcodeVC)
        }))
        
        barcodeVC.present(alert, animated: true)
    }
    
    //If the user chooses to add in the item, this alert is called that asks for user input.
    func alertAddItem(_ barcode: String, _ barcodeVC: BarcodeScannerViewController) {
        let alert = UIAlertController(title: "Item", message: "Enter item name:", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            if let text = textField!.text {
                self.setVCs(text, barcode)
                self.setKeywordFinder(text)
            }
            let ref3 = Database.database().reference()
            ref3.child("Barcodes").child(barcode).setValue(textField?.text)
            update_products_added()
        }))
        barcodeVC.present(alert, animated: true)
    }
    
    //If the user is not connected to the internet this alert is called that tells them to
    //try again.
    func showNoInternetAlert(_ barcodeVC: BarcodeScannerViewController) {
        let alert = UIAlertController(title: "Error", message: "No internet", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default, handler: {action in
            self.resetBarcodeVC(barcodeVC)
        }))
        
        barcodeVC.present(alert, animated: true)
    }
    
    func alertGeneralError(_ barcodeVC: BarcodeScannerViewController) {
          let alert = UIAlertController(title: "Error", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default, handler: {action in
            self.resetBarcodeVC(barcodeVC)
        }))
        
        barcodeVC.present(alert, animated: true)
    }
    
    func setVCs(_ itemN: String, _ barcodeString: String) {
        let priceFinder = PriceFinder()
        priceFinder.priceDelegate = self
        priceFinder.getBestPrices(barcodeString, itemName: itemN)
        curPriceFinder = priceFinder
        
        
        initializeItemVC(itemN, barcodeString)
    }
    
    func setKeywordFinder(_ itemN: String) {
        let keywordFinder = KeywordFinder()
        keywordFinder.keywordDelegate = self
        keywordFinder.errorDelegate = self
        keywordFinder.truncateName(itemN)
        curKeywordFinder = keywordFinder
    }
    
    //In order to update the name of the item for the itemVC, we have to reset the itemVC.
    //This function initializes everything needed, and if wanted will also push the itemVC
    //controller to the navigation stack. You wouldnt want to push it if you are doing a call
    //to get the prices because you have to wait for pricefinder to return.
    func initializeItemVC(_ itemN: String, _ barcodeNum: String = "") {
        itemVC = nil
        itemVC = ItemViewController()
        itemVC?.itemN = itemN
        itemVC?.barcodeNum = barcodeNum
        itemVC?.dismissalDelegate = self
        itemVC?.urlDelegate = self
    }
    
    //Function for if the user presses the search button on the barcodeVC
    @objc func searchAction(sender: Any) {
        pushViewController(searchVC!, animated: true)
    }
    
    @objc func analyticsAction(_ sender: Any) {     
       let swiftcharts = SwiftsChartsViewController()
        pushViewController(swiftcharts, animated: true)
    }
    
    @objc func tutorialAction(_ sender: Any) {
        let tutorialVC = TutorialPageController()
        pushViewController(tutorialVC, animated: true)
    }
  
    @objc func stopScanning(_ sender: Any) {
        resetBarcodeVC(topViewController as! BarcodeScannerViewController)
    }
    
    func resetBarcodeVC(_ barcodeVC: BarcodeScannerViewController) {
        curPriceFinder?.flag = false
        curKeywordFinder?.flag = false
        setBarcodeVCButtons(barcodeVC)
        barcodeVC.reset(animated: true)
    }
    
    func setBarcodeVCButtons(_ controller: BarcodeScannerViewController) {
        let searchBarButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchAction(sender:)))
        let analyticsBarButton = UIBarButtonItem(title: "Graph", style: .plain, target: self, action: #selector(analyticsAction(_:)))
        
        controller.navigationItem.leftBarButtonItems = [searchBarButton, analyticsBarButton]
         controller.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Tutorial", style: .plain, target: self, action: #selector(tutorialAction(_:)))
    }
}

//MARK: Extensions for Delegates

//Function for getting the barcode from the BarcodeScannerViewController
extension MainViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        
        update_products_scanned()

        NetworkManager.isReachable { networkManagerInstance in
           self.barcodeVC = controller
            
            controller.navigationItem.rightBarButtonItem =
                UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.stopScanning(_:)))
            controller.navigationItem.leftBarButtonItems = nil
            
            self.getItemName(code, controller)
        }
        
        NetworkManager.isUnreachable { networkManagerInstance in
            self.showNoInternetAlert(controller)
        }
    }
}

//Function for if the BarcodeScannerViewController encounters an error scanning.
extension MainViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        controller.resetWithError(message: error.localizedDescription)
    }
}

//Function for if the BarcodeScannerViewController dismisses itself
extension MainViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        popViewController(animated: true)
    }
}

//Function for if the ItemViewController dismisses itself.
extension MainViewController: ItemViewDismissalDelegate {
    func itemViewDidDismiss(_ controller: ItemViewController) {
        popViewController(animated: true)
        
        //Either the BarcodeVC or the searchVC can send an item to the ItemVC, so
        //we have to check if the barcodeVC sent it and if so reset the barcodeVC
        if topViewController is BarcodeScannerViewController
        {
            self.barcodeVC = topViewController as? BarcodeScannerViewController
            resetBarcodeVC(barcodeVC!)
        }
    }
}

//Function for handling when the barcodeVC presses the search button in the top right.
extension MainViewController: SearchRequestedDelegate {
    @objc func searchRequested(_ barcodeString: String, _ itemN: String, _ keywordString: [String]) {
        setVCs(itemN, barcodeString)
        itemVC?.keywordString = keywordString
    }
}

extension MainViewController: ItemViewURLDelegate {
    func showSafariVC(_ url: String) {
        update_url()
        guard let url = URL(string: url)else{
            return
        }
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        isNavigationBarHidden = true
        pushViewController(safariVC, animated: true)
    }
}

extension MainViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // pop safari view controller and display navigation bar again
        popViewController(animated: true)
        isNavigationBarHidden = false
    }
}

extension MainViewController: PriceFinderDelegate {
    func returnPrices(_ prices: [String]) {
        DispatchQueue.main.async {
            self.itemVC?.priceArray = prices
    
            if(self.curKeywordFinder!.finished) {
               self.showItem()
            }
        }
    }
    
    func showItem() {
        self.itemVC?.createItems()
        self.searchVC?.giveItemScanned(self.itemVC!.itemN!, self.itemVC!.barcodeNum!, self.itemVC!.keywordString!)
        self.showAlertButtonTapped(self.itemVC!.itemN!, self.itemVC!.barcodeNum!, self.barcodeVC!)
    }
}

extension MainViewController: KeywordFinderDelegate {
    func returnKeywords(_ keywords: [String]) {
        DispatchQueue.main.async {
            self.itemVC?.keywordString = keywords
            
            if(self.curPriceFinder!.finished) {
               self.showItem()
            }
        }
    }
}

extension MainViewController: KeywordErrorDelegate {
    func error() {
        DispatchQueue.main.async {
            self.alertGeneralError(self.topViewController as! BarcodeScannerViewController)
        }
    }
}
