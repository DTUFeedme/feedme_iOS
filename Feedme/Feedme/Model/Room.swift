//
//  Room.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 08/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

struct Room: Decodable {
    var _id: String
    var name: String
}

struct SignalmapWithRoom: Decodable {
    var room: Room
}


