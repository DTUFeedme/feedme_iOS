//
//  Beacon.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 25/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class AppBeacon: Beacon {

        private var currMessurement: Int
        private var latestRssis: [Int]
        private var connectionLost: [Int]
        private var numberOfRssis = 5
    
        init(id: String, uuid: String, building: Building, name: String){
            self.currMessurement = 0
            self.latestRssis = Array(repeating: -100, count: numberOfRssis)
            self.connectionLost = Array(repeating: -100, count: numberOfRssis)
            super.init(id: id, uuid: uuid, name: name, building: building)
        }
    
        func calcAverage() -> Double {
            let filteredList = latestRssis.filter{ $0 != -100 }
            if filteredList.count == 0 {
                return -100
            } else {
                return Double(filteredList.reduce(0,+))/Double(filteredList.count)
            }
        }
        
        func addRssi(rssi: Int){
            
            if currMessurement >= numberOfRssis {
                currMessurement = 0
            }
            if rssi < 0 && rssi >= -100 {
                latestRssis[currMessurement] = rssi
            } else {
                latestRssis[currMessurement] = -100
            }
            currMessurement += 1
        }
}