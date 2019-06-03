//
//  AnswerCell.swift
//  Feedme
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        selectionStyle = UITableViewCell.SelectionStyle.none
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        answerLabel.textColor = .colorOne
        bgView.backgroundColor = .clear
        bgView.layer.cornerRadius = 20
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = .colorOne
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
