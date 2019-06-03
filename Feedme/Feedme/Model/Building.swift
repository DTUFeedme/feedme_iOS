//
//  Building.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 04/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

struct Building: Decodable {
    var _id: String
    var name: String
    var rooms: [Room]?
}
