//
//  Uuid.swift
//  Feedme
//
//  Created by Sebastian on 26/04/2021.
//  Copyright © 2021 Christian Hjelmslund. All rights reserved.
//

import Foundation

struct Uuid: Decodable {
    var uuid: String
    
    enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
    }
}
