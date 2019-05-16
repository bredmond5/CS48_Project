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

//The MainViewController handles switching between the other view controllers. It does
//not have any views of its own as it is a UINavigationController.

class MainViewController: UINavigationController {

    //The controller where all the barcodes searched will show up
    var searchVC: SearchViewController?
    
    //The controller that displays item prices and deals
    var itemVC: ItemViewController?
    
    //The controller that handles scanning the barcode.
    var barcodeVC: BarcodeScannerViewController?
    
    //Here we set up all of the view controllers and their delegates.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Initialize searchVC and set the delegates.
        searchVC = SearchViewController()
        searchVC?.dismissalDelegate = self
        searchVC?.searchRequestedDelegate = self
        
        //Initialize itemVC and set delegates.
        itemVC = ItemViewController()
        itemVC?.dismissalDelegate = self
        
        //initialize barcodeVC and send delegates.
        let barcodeVC = topViewController as! BarcodeScannerViewController
        barcodeVC.codeDelegate = self
        barcodeVC.errorDelegate = self
        barcodeVC.dismissalDelegate = self
        barcodeVC.navigationItem.title = "Scan Barcode" //Set the title of the BarcodeVC
        barcodeVC.isOneTimeSearch = true //So that the barcodeScanner doesnt keep scanning
        barcodeVC.cameraViewController.showsCameraButton = true //for front facing camera
        
        //Give the barcodeVC the search button
        barcodeVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchAction(sender:)))
        
    }
    
    //Function for if the user presses the search button on the barcodeVC
    @objc func searchAction(sender: Any) {
        pushViewController(searchVC!, animated: true)
    }
    
    //Function for getting the item name from the firebase.
    func getItemName(_ barcodeString: String,  _ barcodeVC: BarcodeScannerViewController){

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
                self.alertButtonError(barcode: barcodeString, barcodeVC)
                print("cannot find left range")
                return
            }//Creates left side range
            guard let rightRange = htmlString.range(of: rightSideOfTheValue)else{
                print("cannot find right range")
                return
            }//Creates right side range
            let rangeOfTheValue = leftRange.upperBound..<rightRange.lowerBound //Appends the ranges together
            self.showAlertButtonTapped(String(htmlString[rangeOfTheValue]), barcodeVC) //Displays the product name
        }
        task.resume()
    }
    
    //Shows that the firebase could not find the barcodestring and sends the user back to scanning
    func alertButtonError(barcode: String, _ barcodeVC: BarcodeScannerViewController) {
        let alert = UIAlertController(title: "Error", message: "Could not find " + barcode, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default, handler: {action in
            barcodeVC.reset()
        }))
        
        barcodeVC.present(alert, animated: true)
    }
    
    //Asks the user if the item is correct, and if so goes to the itemVC. If not goes back to scanning
    func showAlertButtonTapped(_ itemN: String, _ barcodeVC: BarcodeScannerViewController){
        let alert = UIAlertController(title: "Item", message: "Is " + itemN + " your item?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {action in
            self.searchVC?.giveItemScanned(itemN)
            self.pushViewController(self.itemVC!, animated: true)
            self.itemVC?.itemN = itemN
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: {action in
            barcodeVC.reset(animated: true)
        }))
        barcodeVC.present(alert, animated: true)
    }
    
    func showNoInternetAlert(_ barcodeVC: BarcodeScannerViewController) {
        let alert = UIAlertController(title: "Error", message: "No internet", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default, handler: {action in
            barcodeVC.reset()
        }))
        
        barcodeVC.present(alert, animated: true)

    }
}

//MARK: Extensions for Delegates

//Function for getting the barcode from the BarcodeScannerViewController
extension MainViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
//        var gotItem = false
        NetworkManager.isReachable { networkManagerInstance in
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
            let barcodeVC = topViewController as! BarcodeScannerViewController
            barcodeVC.reset(animated: true)
        }
        
    }
}

//Function for handling when the searchVC dismisses itself.
extension MainViewController: SearchViewControllerDismissalDelegate {
    func searchViewDidDismiss(_ controller: SearchViewController) {
        popViewController(animated: true)
    }
}

//Function for handling when the barcodeVC presses the search button in the top right.
extension MainViewController: SearchRequestedDelegate {
    @objc func searchRequested(_ item: String) {
        pushViewController(itemVC!, animated: true)
        itemVC?.itemN = item
    }
}
