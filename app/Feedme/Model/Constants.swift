//
//  Constants.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 24/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation
import UIKit

enum ServiceError: LocalizedError {
    case error(description: String)
    
    var errorDescription: String? {
        switch self {
        case let .error(description):
            return description
        }
    }
}

enum JwtExpiredError: LocalizedError{
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



