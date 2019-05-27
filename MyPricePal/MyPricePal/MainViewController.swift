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
    
    //Here we set up all of the view controllers and their delegates.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Initialize searchVC and set the delegates.
        searchVC = SearchViewController()
        searchVC?.dismissalDelegate = self
        searchVC?.searchRequestedDelegate = self
        
        //initialize barcodeVC and send delegates.
        
        
        let barcodeVC = topViewController as! BarcodeScannerViewController
        barcodeVC.codeDelegate = self
        barcodeVC.errorDelegate = self
        barcodeVC.dismissalDelegate = self
        barcodeVC.navigationItem.title = "Scan Barcode" //Set the title of the BarcodeVC
        barcodeVC.isOneTimeSearch = true //So that the barcodeScanner doesnt keep scanning
        
        
        
        barcodeVC.cameraViewController.showsCameraButton = true //for front facing camera
        
        

        
        //Give the barcodeVC the search button
        let searchBarButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchAction(sender:)))
        let analyticsBarButton = UIBarButtonItem(title: "Graph", style: .plain, target: self, action: #selector(analyticsAction(_:)))
        
        barcodeVC.navigationItem.leftBarButtonItems = [searchBarButton, analyticsBarButton]
        
    }
    struct responseJSON: Decodable{
        let response: responseType
    }
    
    struct responseType: Decodable{
        let entities: [Content]
    }
    
    struct Content: Decodable{
        let entityId: String
    }
    func truncateNameThenSetVCs(_ itemN: String, _ barcodeString: String) {
        //DispatchQueue.main.async {
            let urlString = "https://api.textrazor.com/"
            let headers = [
                "x-textrazor-key" : "55864c94efce2b09deef214d17c8de7f0eeb73573655571c5ca9125b"
            ]
            var z : [String] = []
            let x : String = "text=" + itemN
            let y : String = x + "&extractors=entities"
            let postData = NSMutableData(data: y.data(using: String.Encoding.utf8)!)
            let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 1.0)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            print("Before Session")
            let task = URLSession.shared.dataTask(with: request as URLRequest){ (data, response, error) in
                if let data = data{
                    do{
                        print("INSIDE SESSION")
                        let JSONinfo = try JSONDecoder().decode(responseJSON.self, from: data)
                        for i in (JSONinfo.response.entities).indices{
                            if  !(z.contains(JSONinfo.response.entities[i].entityId)) && (JSONinfo.response.entities[i].entityId != ""){
                                z.append(JSONinfo.response.entities[i].entityId)
                                print(z)
                            }
                        }
                        DispatchQueue.main.async {
                            self.setPriceFinderAndVCs(itemN, barcodeString, z)
                        }
                    }catch{
                        print(error)
                    }
                }
            }
            task.resume()
        //}
    }
    
    func getItemName(_ barcodeString: String,  _ barcodeVC: BarcodeScannerViewController){
        let ref = Database.database().reference().child("Barcodes")
    
        ref.child(barcodeString).observeSingleEvent(of: .value, with: {(snapShot) in
            if let val = snapShot.value as? String{
                self.truncateNameThenSetVCs(val, barcodeString)
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
                    self.truncateNameThenSetVCs(String(htmlString[rangeOfTheValue]), barcodeString)
                    
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
                (barcodeVC.reset(animated: true),barcodeVC.navigationItem.rightBarButtonItem = nil)
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
            self.resetBarcodeVC()
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
                self.truncateNameThenSetVCs(text, barcode)
            }
            let ref2 = Database.database().reference()
            ref2.child("Barcodes").child(barcode).setValue(textField?.text)
        }))
        barcodeVC.present(alert, animated: true)
    }
    
    //If the user is not connected to the internet this alert is called that tells them to
    //try again.
    func showNoInternetAlert(_ barcodeVC: BarcodeScannerViewController) {
        let alert = UIAlertController(title: "Error", message: "No internet", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default, handler: {action in
            barcodeVC.reset()
        }))
        
        barcodeVC.present(alert, animated: true)

    }
    
    func setPriceFinderAndVCs(_ itemN: String, _ barcodeString: String, _ keywordString: [String]) {
        let priceFinder = PriceFinder()
        priceFinder.priceDelegate = self
        priceFinder.getBestPrices(barcodeString, itemName: itemN)
        initializeItemVC(itemN, barcodeString, keywordString, shouldPush: false)
        
        self.searchVC?.giveItemScanned(barcodeString, itemN, keywordString)
    }
    
    //In order to update the name of the item for the itemVC, we have to reset the itemVC.
    //This function initializes everything needed, and if wanted will also push the itemVC
    //controller to the navigation stack. You wouldnt want to push it if you are doing a call
    //to get the prices because you have to wait for pricefinder to return.
    func initializeItemVC(_ itemN: String, _ barcodeNum: String = "", _ keywordString: [String], shouldPush: Bool) {
        itemVC = nil
        itemVC = ItemViewController()
//        if(barcodeNum == "") {
//            itemVC?.exact = false
//        }
        itemVC?.itemN = itemN
        itemVC?.keywordString = keywordString
        itemVC?.barcodeNum = barcodeNum
        itemVC?.dismissalDelegate = self
        itemVC?.urlDelegate = self
        
        if(shouldPush) {
            pushViewController(itemVC!, animated: true)
        }
    }
    
    //Function for if the user presses the search button on the barcodeVC
    @objc func searchAction(sender: Any) {
        pushViewController(searchVC!, animated: true)
    }
    
    @objc func analyticsAction(_ sender: Any) {     
//       let swiftcharts = SwiftsChartsViewController()
//        present(swiftcharts, animated: true, completion: nil)
        
    }
  
    @objc func stopScanning(_ sender: Any) {
        flag = false
        resetBarcodeVC()
    }
    
    var flag = true
    
    func resetBarcodeVC() {
        barcodeVC?.reset(animated: true)
        barcodeVC?.navigationItem.rightBarButtonItem = nil
    }
}

//MARK: Extensions for Delegates

//Function for getting the barcode from the BarcodeScannerViewController
extension MainViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {

        NetworkManager.isReachable { networkManagerInstance in
           self.barcodeVC = controller
            
            controller.navigationItem.rightBarButtonItem =
                UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.stopScanning(_:)))
            
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
            self.barcodeVC = topViewController as! BarcodeScannerViewController
            resetBarcodeVC()
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
    @objc func searchRequested(_ barcodeString: String, _ itemN: String, _ keywordString: [String]) {
        setPriceFinderAndVCs(itemN, barcodeString, keywordString)
    }
}

extension MainViewController: ItemViewURLDelegate {
    func showSafariVC(_ url: String) {
        guard let url = URL(string: url)else{
            print("here")
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
            if(self.flag){
            self.showAlertButtonTapped(self.itemVC!.itemN!, self.itemVC!.barcodeNum!, self.barcodeVC!)
            }
            //else{
                self.flag = true
                
            //}
        }
    }
}
