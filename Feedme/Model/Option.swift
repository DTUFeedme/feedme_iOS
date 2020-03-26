//
//  Option.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 27/06/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation

// The webservice returns objects with the fields _id and value for a lot of different functionc calls. For example a question from the service can have the fields _id and value, but so can an answer. Check the files (AnsweredQuestion and Answered feedback for example).

struct Option: Decodable {
    var _id: String
    var value: String
}
