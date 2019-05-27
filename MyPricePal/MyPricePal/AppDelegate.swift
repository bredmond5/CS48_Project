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
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        UINavigationBar.appearance().barTintColor = .black
        UIBarButtonItem.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
        
//        let defaults = UserDefaults.standard
//        if defaults.object(forKey: "isFirstTime") == nil {
//            defaults.set("No", forKey: "isFirstTime")
//            defaults.synchronize()
//
//            let tutorialVC = TutorialPageController()
//            window?.rootViewController = MainViewController(rootViewController: tutorialVC)
//        }else{
            let barcodeVC = BarcodeScannerViewController()
            window?.rootViewController = MainViewController(rootViewController: barcodeVC)
       // }
        
        //Sets the window and mainviewcontroller programatically.
        FirebaseApp.configure();
        return true
    }
}

