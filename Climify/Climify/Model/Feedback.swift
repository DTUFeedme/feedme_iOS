//
//  Feedback.swift
//  Climify
//
//  Created by Christian Hjelmslund on 28/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class Feedback: NSObject {
    
    var questionID: String
    var userID: String
    var answer: Int
    
    init(questionID: String, answer: Int) {
        self.questionID = questionID
        self.answer = answer
        self.userID = "userID"
        if let userID = UserDefaults.standard.string(forKey: "userID"){
            self.userID = userID
        }
    }
    
    convenience override init(){
        self.init(questionID: "", answer: -1)
    }
}
