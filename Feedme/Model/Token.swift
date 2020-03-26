//
//  Token.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 03/06/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation

struct Token: Decodable {
    var token: String
    
    enum CodingKeys: String, CodingKey {
        case token = "x-auth-token"
    }
}
