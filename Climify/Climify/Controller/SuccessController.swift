//
//  SuccessController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 22/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class SuccessController: UIViewController {
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var thanksLabel: UILabel!
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var animationViewLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.isHidden = true
        thanksLabel.isHidden = true
        returnButton.isHidden = true
        
        returnButton.backgroundColor = .clear
        returnButton.layer.cornerRadius = 20
        returnButton.layer.borderWidth = 2
        returnButton.layer.borderColor = UIColor.white.cgColor
        
        let shape = CAShapeLayer()
        animationViewLabel.text = "sending..."
        animationViewLabel.textColor = .myCyan()
        animationView.layer.addSublayer(shape)
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = .myCyan()
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
}
