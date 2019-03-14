//
//  Feedback.swift
//  Climify
//
//  Created by Christian Hjelmslund on 07/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class Feedback: NSObject {

    var userID: String?
    var roomID: String
    var answers: [Answer]
    
    init(answers: [Answer], roomID: String){
        self.answers = answers
        self.roomID = roomID
        
        //self.userID = "no user ID"
        if let userID = UserDefaults.standard.string(forKey: "userID"){
            self.userID = userID
        }
    }
    
    convenience override init(){
        self.init(answers: [], roomID: "xxx")
    }
}
