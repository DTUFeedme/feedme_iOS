//
//  MainController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 03/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.tabBar.isTranslucent = false
    }
    

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let viewController = self.viewControllers?[1] as? DataTabController {
            if let navController = self.viewControllers![0] as? UINavigationController {
                if let feedbackVC = navController.viewControllers.first as? FeedbackTabController{
                    print(feedbackVC.currentRoomID)
                    viewController.currentRoomId = feedbackVC.currentRoomID
                    viewController.chosenRoomId = feedbackVC.currentRoomID
                    viewController.updateCurrentRoomIdLabel()
                }
            }
        }
    }
    func addNewTabBarItem(){
        let sb = UIStoryboard(name: "Feedback", bundle: nil)
        if let scanVC = sb.instantiateViewController(withIdentifier: "Scanning") as? ScanningViewController {
            let image = #imageLiteral(resourceName: "beacon_glyph")
            scanVC.tabBarItem = UITabBarItem(title: "Scan Room", image: image, selectedImage: image)
            self.viewControllers?.append(scanVC)
        }
    }
}

