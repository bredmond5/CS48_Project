//
//  AppDelegate.swift
//  MyPricePal
//
//  Created by Brice Redmond on 4/15/19.
//  Copyright © 2019 CS48. All rights reserved.
//

import UIKit
import Firebase
import BarcodeScanner

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Sets the window and mainviewcontroller programatically.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        //Create a BarcodeScannerViewController and pass it to the MainViewController
        let barcodeVC = BarcodeScannerViewController()
        window?.rootViewController = MainViewController(rootViewController: barcodeVC)

        FirebaseApp.configure();
        return true
    }
}

