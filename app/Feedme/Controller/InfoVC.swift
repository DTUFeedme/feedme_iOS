//
//  InfoVC.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 14/08/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class InfoVC: UIViewController {
    var locationEstimator: LocationEstimator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationEstimator = appDelegate.locationEstimator
        
    }
    
    @IBAction func demoButton(_ sender: Any) {
        locationEstimator.demo = !locationEstimator.demo;
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
