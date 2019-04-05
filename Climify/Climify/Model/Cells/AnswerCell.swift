//
//  AnswerCell.swift
//  Climify
//
//  Created by Christian Hjelmslund on 14/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class AnswerCell: UITableViewCell {

    
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.backgroundColor = .myCyan()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        selectionStyle = UITableViewCell.SelectionStyle.none
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgView.layer.cornerRadius = 20
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
    
    

}
