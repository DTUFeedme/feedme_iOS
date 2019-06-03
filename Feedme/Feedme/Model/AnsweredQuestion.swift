//
//  AnsweredQuestion.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 13/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation

struct AnsweredQuestion: Decodable {
    var question: String
    var questionId: String
    var answeredCount: Int
}
