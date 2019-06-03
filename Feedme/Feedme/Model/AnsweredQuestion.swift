//
//  AnsweredQuestion.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 13/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation

struct AnsweredQuestion: Decodable {
    var question: SubAnsweredQuestion
    var timesAnswered: Int
}

struct SubAnsweredQuestion: Decodable {
    var value: String
    var _id: String
}
