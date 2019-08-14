//
//  TermsOfServiceVC.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 14/08/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class TermsOfServiceVC: UIViewController, UITextViewDelegate {
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var scrollview: UITextView!{
        didSet {
            scrollview.delegate = self
        }
    }
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.isHidden = true
        buttonHeight.constant = 0
        // Do any additional setup after loading the view.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y + scrollView.bounds.height < scrollView.contentSize.height {
            buttonHeight.constant = 0
            doneButton.isHidden = true
        } else {
            doneButton.isHidden = false
            buttonHeight.constant = 36
        }
   
    }
    
    
    @IBAction func toMain(_ sender: Any) {
        self.performSegue(withIdentifier: "toMain", sender: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
 
}
