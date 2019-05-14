//
//  QuestionCell.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 24/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class QuestionCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var howManyTimesAnsweredLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.backgroundColor = .myCyan()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = UITableViewCell.SelectionStyle.none
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        questionLabel.textColor = .white
        howManyTimesAnsweredLabel.textColor = .white
        bgView.backgroundColor = .clear
        bgView.layer.cornerRadius = 20
        bgView.layer.borderWidth = 1
        bgView.layer.cornerRadius = 15
        bgView.layer.shadowOpacity = 1
        bgView.layer.shadowOffset = CGSize.zero
        bgView.layer.shadowColor = UIColor.white.cgColor
        bgView.layer.shadowRadius = 10
        bgView.layer.borderColor = UIColor.white.cgColor
    }
    func flash() {
        
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.1
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 2
        
        layer.add(flash, forKey: nil)
    }

}
