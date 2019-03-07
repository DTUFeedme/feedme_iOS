//
//  Question.swift
//  Climify
//
//  Created by Christian Hjelmslund on 07/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class Question: NSObject {
    
    var questionID: String
    var question: String
    
    init(questionID: String, question: String) {
        self.questionID = questionID
        self.question = question
    }
    
    convenience override init(){
        self.init(questionID: "", question: "")
    }
}
