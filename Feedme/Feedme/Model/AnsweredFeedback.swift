//
//  AnsweredFeedback.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 13/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation

struct AnsweredFeedback: Decodable {
    var answer: Option
    var timesAnswered: Int
}
