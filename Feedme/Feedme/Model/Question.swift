//
//  Question.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 07/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit


struct Question: Decodable {
    
    var _id: String
    var value: String
    var answerOptions: [Option]
}
