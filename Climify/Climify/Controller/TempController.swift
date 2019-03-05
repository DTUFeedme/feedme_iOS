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
        
        let url = URL(string: "http://localhost:3000/questions")
        let urlRequest = URLRequest(url: url!)
        
        
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            
            if error != nil {
                print(error as Any)
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [AnyObject]
                print(json.count)
            } catch let error {
                print(error)
            }
        }.resume()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == nextSegue) {
            if let humidController = segue.destination as? HumidController{
                humidController.feedback = feedback
            }
        }
    }
}
