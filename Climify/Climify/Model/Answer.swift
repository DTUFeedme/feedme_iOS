//
//  Feedback.swift
//  Climify
//
//  Created by Christian Hjelmslund on 28/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class Answer: NSObject {
    
    var questionID: String
    var answerValue: String
    var answerID: String
    
    init(questionID: String, answerValue: String, answerID: String) {
        self.questionID = questionID
        self.answerValue = answerValue
        self.answerID = answerID
    }
    
    convenience override init(){
        self.init(questionID: "", answerValue: "", answerID: "")
    }
}
