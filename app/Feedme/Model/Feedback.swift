//
//  Feedback.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 07/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

struct Feedback {

    var authToken: String?
    var roomID: String
    var questionId: String
    var answerId: String
    
    init(answerId: String, roomID: String, questionId: String){
        self.answerId = answerId
        self.roomID = roomID
        self.questionId = questionId
        
        if let token = UserDefaults.standard.string(forKey: "x-auth-token"){
            self.authToken = token
        }
    }
}
