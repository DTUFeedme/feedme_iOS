//
//  Feedback.swift
//  Climify
//
//  Created by Christian Hjelmslund on 28/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class Feedback: NSObject {
    
    enum Temperature:Int {
        case empty = -1
        case low = 0
        case fine = 1
        case high = 2
    }
    
    enum Humidity:Int {
        case empty = -1
        case low = 0
        case fine = 1
        case high = 2
    }
    
    enum Placeholder:Int {
        case empty = -1
        case low = 0
        case fine = 1
        case high = 2
    }
    
    var temperature: Temperature
    var humidity: Humidity
    var placeholder: Placeholder
    
    init(temperature: Temperature, humidity: Humidity, placeholder: Placeholder) {
        self.temperature = temperature
        self.humidity = humidity
        self.placeholder = placeholder
    }
    
    convenience override init(){
        self.init(temperature: Temperature.empty, humidity: Humidity.empty, placeholder: Placeholder.empty)
    }

}
