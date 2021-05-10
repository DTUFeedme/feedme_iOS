//
//  SuccessController.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 22/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class SuccessVC: UIViewController {
    
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var thanksLabel: UILabel!
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var animationViewLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        runAnimation()
    }
    
    @IBAction func returnButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {})
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupUI(){
        descriptionLabel.isHidden = true
        thanksLabel.isHidden = true
        returnButton.isHidden = true
        
        returnButton.backgroundColor = .clear
        returnButton.layer.cornerRadius = 20
        returnButton.layer.borderWidth = 2
        returnButton.layer.borderColor = UIColor.colorOne?.cgColor
    }
    
    func runAnimation(){
        
        let shape = CAShapeLayer()
        animationViewLabel.text = "sending..."
        
        animationViewLabel.textColor = .colorOne
        animationView.layer.addSublayer(shape)
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = .colorOne
        shape.lineCap = CAShapeLayerLineCap.round
        shape.strokeEnd = 0
        shape.lineWidth = 10
        
        let path = CGMutablePath()
        path.addEllipse(in: animationView.layer.bounds)
        shape.path = path
        
        let animcolor = CABasicAnimation(keyPath: "strokeEnd")
        animcolor.toValue = 1
        animcolor.duration = 1
        animcolor.isRemovedOnCompletion = false
        shape.add(animcolor, forKey: "strokeEnd")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.animationViewLabel.text = "success!"
            UIView.animate(withDuration: 1, animations: {
                self.animationViewLabel.alpha = 0
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.animationView.isHidden = true
            self.descriptionLabel.isHidden = false
            self.thanksLabel.isHidden = false
            self.returnButton.isHidden = false
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func feedBack(_ sender: UIButton) {
        
    }

}
