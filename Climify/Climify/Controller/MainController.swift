//
//  MainController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 03/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class MainController: UITabBarController, UITabBarControllerDelegate {

    @IBOutlet weak var myBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}

