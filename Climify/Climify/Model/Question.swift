//
//  Question.swift
//  Climify
//
//  Created by Christian Hjelmslund on 07/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit


struct Question {
    
    
    var id: String
    var question: String
    var answerOptions: [answerOption]
    
    struct answerOption {
        var id: String
        var value: String
    }
    
    init(questionID: String, question: String, answerOptions: [answerOption]) {
        self.answerOptions = answerOptions
        self.id = questionID
        self.question = question
    }
    
    init(){
        self.init(questionID: "", question: "", answerOptions: [])
    }
}
