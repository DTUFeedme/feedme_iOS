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
    var answerOptions: [answerOption]
    
    struct answerOption {
        var id: String
        var value: String
    }
    
    init(questionID: String, question: String, answerOptions: [answerOption]) {
        self.answerOptions = answerOptions
        self.questionID = questionID
        self.question = question
    }
    
    convenience override init(){
        self.init(questionID: "", question: "", answerOptions: [])
    }
}
