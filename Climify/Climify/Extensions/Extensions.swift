//
//  Extensions.swift
//  Climify
//
//  Created by Christian Hjelmslund on 09/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation


import Foundation
import UIKit

// BUTTON EXTENSION
extension UIButton {
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.2
        pulse.fromValue = 1
        pulse.toValue = 1.2
        pulse.autoreverses = true
        pulse.repeatCount = 2
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    
    func pulseInfite(){
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1
        pulse.toValue = 1.1
        pulse.autoreverses = true
        pulse.repeatCount = 500
        layer.add(pulse, forKey: "pulse")
    }
    
    func flash() {
        
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.06
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 4
        
        layer.add(flash, forKey: nil)
    }
    
    func rotate(rotate: Double) {
        UIView.animate(withDuration: 0.5) {
            self.transform = CGAffineTransform(rotationAngle: CGFloat((Double.pi)*rotate))
        }
    }
    func rotateImage() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = CGFloat.pi
        rotationAnimation.fillMode = CAMediaTimingFillMode.forwards
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.duration = 0.5
        
        self.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
}

// COLORS EXTENSION
extension UIColor {
    class func myCyan () -> UIColor { return UIColor(red: 25/255, green: 181/255, blue: 178/255, alpha: 1) }
    class func myDark () -> UIColor { return UIColor(red: 15/255, green: 20/255, blue: 15/255, alpha: 1) }
    class func myGray () -> UIColor { return UIColor(red: 71/255, green: 71/255, blue: 79/255, alpha: 1) }
    class func myGreen () -> UIColor { return UIColor(red:103/255, green:211/255, blue:141/255, alpha: 1)}
    class func myRed () -> UIColor { return UIColor(red:175/255, green:0/255, blue:0/255, alpha: 1)}
    
    
}

extension CGColor {
    class func myCyan () -> CGColor { return UIColor(red: 25/255, green: 181/255, blue: 178/255, alpha: 1).cgColor }
    class func myDark () -> CGColor { return UIColor(red: 15/255, green: 20/255, blue: 15/255, alpha: 1).cgColor }
    class func myGreen () -> CGColor { return UIColor(red:103/255, green:211/255, blue:141/255, alpha: 1).cgColor }
    class func myRed () -> CGColor { return UIColor(red:175/255, green:0/255, blue:0/255, alpha: 1).cgColor }
}

// FONTS
extension UIFont {
    class func avenir18() -> UIFont { return UIFont(name: "Avenir Next", size: 18)! }
    class func avenir20() -> UIFont { return UIFont(name: "Avenir Next", size: 22)! }
    class func navigationFont() -> UIFont { return UIFont(name: "Avenir Next", size: 26)! }
}

// COLLECTIONS (ARRAYS, LISTS etc.)
extension Collection {
    
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UserDefaults {
    func contains(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}

// VIEW
extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}



