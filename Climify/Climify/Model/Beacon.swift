//
//  Beacon.swift
//  Climify
//
//  Created by Christian Hjelmslund on 25/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class Beacon: NSObject {

        var id: String
        var name: String
        var currMessurement: Int
        var latestRssis: [Int]
    
        init(id: String, rssi: Int, name: String){
            self.currMessurement = 0
            self.id = id
            self.name = name
            self.latestRssis = Array(repeating: -200, count: 5)
            super.init()
            self.addRssi(rssi: rssi)
        }
    
        convenience override init(){
            self.init(id: "", rssi: -200, name: "")
        }
    
        func calcAverage() -> Double {
            return Double(latestRssis.reduce(0,+))/Double(latestRssis.count)
        }
        
        func addRssi(rssi: Int){
            
            if currMessurement > 4 {
                currMessurement = 0
            }
            if rssi < 0 {
                latestRssis[currMessurement] = rssi
            }
            currMessurement += 1
        }
}
