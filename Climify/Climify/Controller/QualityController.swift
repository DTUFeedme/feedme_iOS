//
//  QualityControllerViewController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 28/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class QualityController: UIViewController {

    var feedback = Feedback.init()
    let nextSegue = "feedbackreceived"
    
    @IBAction func humidityFeedback(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            feedback.placeholder = .low
        case 1:
            feedback.placeholder = .fine
        case 2:
            feedback.placeholder = .high
        default:
            feedback.placeholder = .empty
        }
        self.performSegue(withIdentifier: nextSegue, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == nextSegue) {
//            if let qualController = segue.destination as? QualityController{
//                qualController.feedback = feedback
//            }
//        }
//    }
    
}
