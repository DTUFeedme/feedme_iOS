//
//  Question.swift
//  Feedme
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
}
