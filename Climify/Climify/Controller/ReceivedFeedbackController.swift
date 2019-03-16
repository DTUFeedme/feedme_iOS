//
//  FeedbackReceivedControllerViewController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 11/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class ReceivedFeedbackController: UIViewController {

    @IBOutlet weak var feedbackImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
