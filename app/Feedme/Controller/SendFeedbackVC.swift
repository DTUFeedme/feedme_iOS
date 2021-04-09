//
//  SendFeedbackVC.swift
//  Feedme
//
//  Created by Mac on 08/04/2021.
//  Copyright © 2021 Christian Hjelmslund. All rights reserved.
//

import UIKit

class SendFeedbackVC: UIViewController,UITextViewDelegate {

    @IBOutlet weak var textView:UITextView!
    @IBOutlet weak var sendFbBtn:UIButton!
    @IBOutlet weak var submittedFbView:UIView!
    var feedmeNS: FeedmeNetworkService!
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
    let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI(){
        alert.view.tintColor = UIColor.black
    
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = .white
        feedmeNS = appDelegate.feedmeNS
        submittedFbView.isHidden = true
        textView.delegate = self
        textView.text = "Enter feedback here"
        textView.textColor = UIColor.lightGray
        sendFbBtn.layer.cornerRadius = sendFbBtn.layer.frame.height/2
        sendFbBtn.layer.borderWidth = 1
        sendFbBtn.layer.borderColor = UIColor.green.cgColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    @IBAction func sendBtn( _ sender:UIButton){
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        feedmeNS.sendFeedback(feedback: textView.text) {response, error  in
            //dismiss(animated: alert, completion: nil)
            self.alert.dismiss(animated: false, completion: nil)
            if error == nil  {
                self.submittedFbView.isHidden = false
            } else {
                self.showAlert()
            }
        }
    }

    @IBAction func backBtn( _ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }

    func showAlert(){
        let alert = UIAlertController(title: "Error", message: "Somthing went wrong try again please.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
                case .default:
                print("default")
                   
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
                
            @unknown default:
                print("destructive")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
        }
    }

}
