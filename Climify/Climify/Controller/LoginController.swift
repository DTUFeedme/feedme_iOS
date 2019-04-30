//
//  LoginController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 27/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
    private let api = ClimifyAPI()
    private var email = ""
    private var password = ""
  
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    @IBAction func email(_ sender: UITextField) {
        if let text = sender.text {
            email = text
        }
    }
   
    @IBAction func password(_ sender: UITextField) {
        if let text = sender.text {
            password = text
        }
    }
    
    @IBAction func printContent(_ sender: Any) {
        api.login(email: email, password: password) { result, description in
            self.descriptionLabel.text = description
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}
