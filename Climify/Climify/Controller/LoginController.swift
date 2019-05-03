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
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var login: UIButton!
    
    @IBAction func email(_ sender: UITextField) {
        if let text = sender.text {
            email = text
        }
    }
    @IBAction func loginAction(_ sender: Any) {
        api.login(email: email, password: password) { result, description in
            if description == "Login successful" {
                if let tbc = self.tabBarController as? TabBarController {
                    if tbc.viewControllers?.count == 2 {
                        tbc.addNewTabBarItem()
                    }
                }
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                self.backgroundView.shake()
                self.descriptionLabel.text = description
            }
        }
    }

    @IBAction func password(_ sender: UITextField) {
        if let text = sender.text {
            password = text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

