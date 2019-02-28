//
//  HumidController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 28/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class HumidController: UIViewController {

    var feedback = Feedback.init()
    var nextSegue = "humidtoquality"
    
    @IBAction func humidityFeedback(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            feedback.humidity = .low
        case 1:
            feedback.humidity = .fine
        case 2:
            feedback.humidity = .high
        default:
            feedback.humidity = .empty
        }
        self.performSegue(withIdentifier: nextSegue, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == nextSegue) {
            if let qualController = segue.destination as? QualityController{
                qualController.feedback = feedback
            }
        }
    }

}
