//
//  AppDelegate.swift
//  trusty
//
//  Created by Sergey Mihalenko on 15.02.18.
//  Copyright © 2018 trustyfund. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .black
        window?.makeKeyAndVisible()
        
        window?.rootViewController = ViewController()
        
        return true
    }
    
}

