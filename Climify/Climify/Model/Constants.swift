//
//  Constants.swift
//  Climify
//
//  Created by Christian Hjelmslund on 24/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation
import UIKit

struct HTTPCode {
    static let SUCCESS = 200
    static let ERROR = 400
    static let REDIRECTION = 300
    static let CLIENTERROR = 400
    static let SERVERERROR = 500
    static let JSONERROR = 600
}

enum ServiceError: LocalizedError {
    case error(description: String)
    
    var errorDescription: String? {
        switch self {
        case let .error(description):
            return description
        }
    }
}

enum Time: String {
    case day = "day"
    case week = "week"
    case month = "month"
    case all = "year"
}



