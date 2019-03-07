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
        // Override point for customization after application launch.
        
        let defaults = UserDefaults.standard
        
        let launchedBefore = defaults.bool(forKey: "launchedBefore")
        
        if launchedBefore {
            print("User ID: ",defaults.string(forKey: "userID")!)
        }
        else {
            let networkService = NetworkService()
            networkService.initUser()
            defaults.set(true, forKey: "launchedBefore")
        }
        
        
        let green = UIColor(red: 28/255, green: 177/255, blue: 118/255, alpha: 1)
        let darkGreen = UIColor(red: 14/255, green: 120/255, blue: 100/255, alpha: 1)
        UITabBar.appearance().barTintColor = green
        UITabBar.appearance().tintColor = darkGreen
        UITabBar.appearance().unselectedItemTintColor = .white
        
        
        let navigationFont = UIFont(name: "Avenir Next", size: 28)
        UINavigationBar.appearance().barTintColor = green
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: darkGreen, NSAttributedString.Key.font: navigationFont!]
  
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

