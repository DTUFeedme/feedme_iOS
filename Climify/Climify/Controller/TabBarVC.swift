//
//  MainController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 03/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController, UITabBarControllerDelegate {
    
    var climify: ClimifyAPI!
    var locationEstimator: LocationEstimator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.tabBar.isTranslucent = false
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
   
        if let dataVC = viewController as? DataVC {
            if let navController = self.viewControllers?[0] as? UINavigationController {
                if let feedbackVC = navController.viewControllers.first as? FeedbackVC{
                    dataVC.currentRoomId = feedbackVC.currentRoomID
                    dataVC.chosenRoomId = feedbackVC.currentRoomID
                    dataVC.currentRoom = feedbackVC.currentRoomName
                    dataVC.chosenRoom = feedbackVC.currentRoomName
                    dataVC.updateCurrentRoomNameLabel()
                }
            }
        }
            
        else if let navController = self.viewControllers?[0] as? UINavigationController {
            if let feedbackVC = navController.viewControllers.first as? FeedbackVC{
                if let dataVC = self.viewControllers?[1] as? DataVC {
                    feedbackVC.currentRoomID = dataVC.currentRoomId
                    feedbackVC.currentRoomName = dataVC.currentRoom
                    feedbackVC.updateCurrentRoomNameLabel()
                }
            }
        }
    }


    func addNewTabBarItem(){
        let sb = UIStoryboard(name: "Feedback", bundle: nil)
        if let scanVC = sb.instantiateViewController(withIdentifier: "Scanning") as? ScanningVC {
            let image = #imageLiteral(resourceName: "beacon_glyph")
            scanVC.tabBarItem = UITabBarItem(title: "Scan Room", image: image, selectedImage: image)
            self.viewControllers?.append(scanVC)
        }
    }
}

