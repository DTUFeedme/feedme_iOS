//
//  FeedbackController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 26/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class TempController: UIViewController {
    
    var feedback = Feedback.init()
    let nextSegue = "temptohumid"
    
    @IBAction func temperatureFeedback(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            feedback.temperature = .low
        case 1:
            feedback.temperature = .fine
        case 2:
            feedback.temperature = .high
        default:
            feedback.temperature = .empty
        }
        self.performSegue(withIdentifier: nextSegue, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == nextSegue) {
            if let humidController = segue.destination as? HumidController{
                humidController.feedback = feedback
            }
        }
    }
}
