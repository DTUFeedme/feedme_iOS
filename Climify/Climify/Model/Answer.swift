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
    var answer: Int
    
    init(questionID: String, answer: Int) {
        self.questionID = questionID
        self.answer = answer 
    }
    
    convenience override init(){
        self.init(questionID: "", answer: -1)
    }
}
