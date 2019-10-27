//
//  AppDelegate.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 07/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var feedmeNS: FeedmeNetworkService?
    var locationEstimator: LocationEstimator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        var vc = UIViewController()
        if !UserDefaults.standard.contains(key: "hasLoggedInBefore") {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            
            if !UserDefaults.standard.contains(key: "didReadTermsOfService") {
                UserDefaults.standard.set(true, forKey: "didReadTermsOfService")
                vc = sb.instantiateViewController(withIdentifier: "privacypolicy")
            } else {
                vc = sb.instantiateViewController(withIdentifier: "main")
            }
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
            
        }

        feedmeNS = FeedmeNetworkService()
        locationEstimator = LocationEstimator(service: feedmeNS!)
        
        if UserDefaults.standard.contains(key: "isAdmin") {
            let admin = UserDefaults.standard.bool(forKey: "isAdmin")
            if admin {
                if let tbc = vc as? TabBarVC {
                    tbc.addNewTabBarItem()
                }
            }
        }
        
    
        let bgColor = UIColor(named: "backgroundColor")
        let color = UIColor(named: "colorOne")
        
        UINavigationBar.appearance().barTintColor = color
        UITabBar.appearance().barTintColor = color
        UITabBar.appearance().tintColor = bgColor
        UITabBar.appearance().unselectedItemTintColor = .black
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "backgroundColor")!, NSAttributedString.Key.font: UIFont.navigationFont()]
        return true
    }
}

