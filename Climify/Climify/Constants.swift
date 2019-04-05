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
    static let SUCCES = 200
    static let REDIRECTION = 300
    static let CLIENTERROR = 400
    static let SERVERERROR = 500
}

let TOKEN = UserDefaults.standard.string(forKey: "x-auth-token")


