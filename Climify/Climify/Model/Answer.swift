//
//  Feedback.swift
//  Climify
//
//  Created by Christian Hjelmslund on 28/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

struct Answer {
    
    var questionID: String
    var answerValue: String
    var id: String
    
    init(questionID: String, answerValue: String, answerID: String) {
        self.questionID = questionID
        self.answerValue = answerValue
        self.id = answerID
    }
    
    init(){
        self.init(questionID: "", answerValue: "", answerID: "")
    }
}
