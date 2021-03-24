//
//  RefreshToken.swift
//  Feedme
//
//  Created by Sebastian on 19/03/2021.
//  Copyright © 2021 Christian Hjelmslund. All rights reserved.
//

import Foundation


struct RefreshToken: Decodable {
    var refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refreshToken"
    }
}
