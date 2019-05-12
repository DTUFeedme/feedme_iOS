//
//  AppDelegate.swift
//  Climify
//
//  Created by Christian Hjelmslund on 07/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "main")
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        if UserDefaults.standard.contains(key: "isAdmin") {
            let admin = UserDefaults.standard.bool(forKey: "isAdmin")
            if admin {
                if let tbc = vc as? TabBarVC {
                    tbc.addNewTabBarItem()
                }
            }
        }

        UINavigationBar.appearance().barTintColor = .myGray()
        UITabBar.appearance().barTintColor = .myGray()
        UITabBar.appearance().tintColor = .white
        UITabBar.appearance().unselectedItemTintColor = .myCyan()
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.myCyan(), NSAttributedString.Key.font: UIFont.navigationFont()]
        return true
    }
}

