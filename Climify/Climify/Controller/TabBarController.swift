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
    }

    func addNewTabBarItem(){
        let sb = UIStoryboard(name: "Data", bundle: nil)
        
        if let roomChooserVC = sb.instantiateViewController(withIdentifier: "roomchooser") as? RoomChooserController {
            roomChooserVC.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 3)
            self.viewControllers?.append(roomChooserVC)
        }
        
    }
}

