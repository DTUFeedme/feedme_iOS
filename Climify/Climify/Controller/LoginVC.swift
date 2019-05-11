//
//  LoginController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 27/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var login: UIButton!
    private var email = ""
    private var password = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        backgroundView.layer.cornerRadius = 15
        backgroundView.layer.shadowOpacity = 1
        backgroundView.layer.shadowOffset = CGSize.zero
        backgroundView.layer.shadowRadius = 10
        login.setTitleColor(.myDark(), for: .normal)
        login.backgroundColor = .clear
        login.layer.cornerRadius = 15
        login.layer.borderWidth = 2
        login.layer.borderColor = .myDark()
    }
   
    @IBAction func email(_ sender: UITextField) {
        if let text = sender.text {
            email = text
        }
    }
    @IBAction func loginAction(_ sender: Any) {
        ClimifyAPI.sharedInstance.login(email: email, password: password) { error in
            if error == nil {
                if let tbc = self.tabBarController as? TabBarVC {
                    if tbc.viewControllers?.count == 2 {
                        tbc.addNewTabBarItem()
                    }
                }
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                self.backgroundView.shake()
                self.descriptionLabel.text = error?.errorDescription
            }
        }
    }
    
    @IBAction func password(_ sender: UITextField) {
        if let text = sender.text {
            password = text
        }
    }
}
