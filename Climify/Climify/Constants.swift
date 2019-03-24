//
//  Constants.swift
//  Climify
//
//  Created by Christian Hjelmslund on 24/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation
import UIKit

struct Colors {
    static let cyan = UIColor(red: 25/255, green: 181/255, blue: 178/255, alpha: 1)
    static let dark = UIColor(red: 15/255, green: 20/255, blue: 15/255, alpha: 1)
}
struct Fonts {
    static let avenir18 =  UIFont(name: "Avenir Next", size: 18)
    static let avenir20 = UIFont(name: "Avenir Next", size: 22)
    static let navigationfont = UIFont(name: "Avenir Next", size: 26)
}

struct HTTPCode {
    static let SUCCES = 200
    static let REDIRECTION = 300
    static let CLIENTERROR = 400
    static let SERVERERROR = 500
}
