//
//  LoginController.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 27/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var passwordTextfield: UITextField!{
        didSet {
            passwordTextfield.tintColor = .colorOne
            passwordTextfield.setIcon(#imageLiteral(resourceName: "lock"))
        }
    }
    @IBOutlet weak var emailTextfield: UITextField!{
        didSet {
            emailTextfield.tintColor = .colorOne
            emailTextfield.setIcon(#imageLiteral(resourceName: "profile_glyph"))
        }
    }
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var login: UIButton!
    private var email = ""
    private var password = ""
    var feedmeNS: FeedmeNetworkService!
    
    
    override func viewDidLoad() {
        feedmeNS = appDelegate.feedmeNS
        super.viewDidLoad()
        login.backgroundColor = .clear
        login.layer.cornerRadius = 20
        login.layer.borderWidth = 1
        login.layer.borderColor = .colorOne
    }
    
   
    @IBAction func email(_ sender: UITextField) {
        if let text = sender.text {
            email = text
        }
    }
    @IBAction func loginAction(_ sender: Any) {
        feedmeNS.login(email: email, password: password) { error in
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func tapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func password(_ sender: UITextField) {
        if let text = sender.text {
            password = text
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
