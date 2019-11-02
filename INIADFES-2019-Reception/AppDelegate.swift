//
//  AppDelegate.swift
//  INIADFES-2019-Reception
//
//  Created by Kentaro on 2019/10/28.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import UIKit
import Alamofire
import KeychainAccess
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, StarIoExtManagerDelegate {
    var manager:StarIoExtManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let config = Configuration()
        let keyStore = Keychain.init(service: config.value(forKey: "keychain_identifier"))
        if keyStore["apiKey"] != nil{}else{
            let queue = DispatchQueue.global(qos: .utility)
            let semaphore = DispatchSemaphore.init(value: 0)
            
            Alamofire.request("\(config.value(forKey: "base_url"))/api/v1/user/new", method: .post, parameters: ["device_type":"reception_device"]).responseJSON(queue: queue){response in
                guard let value = response.result.value else{
                    return
                }
                
                let createUserResultJsonObject = JSON(value)
                keyStore["apiKey"] = createUserResultJsonObject["secret"].stringValue
                
                semaphore.signal()
            }
            
            semaphore.wait()
            
            UIApplication.shared.open(URL(string: "\(config.value(forKey: "base_url"))/auth/circle?api_key=\(keyStore["apiKey"]!)")!)
        }
        
        manager = StarIoExtManager.init(type: .standard, portName: "BT:mC-Print3", portSettings: "", ioTimeoutMillis: 10000)!
        manager.delegate = self
        manager.connectAsync()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func didPrinterOnline() {
        print("online")
    }
}

