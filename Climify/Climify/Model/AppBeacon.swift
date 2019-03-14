//
//  Beacon.swift
//  Climify
//
//  Created by Christian Hjelmslund on 25/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class AppBeacon: Beacon {

        var currMessurement: Int
        var latestRssis: [Int]
    
        init(id: String, uuid: String, location: String, room: Room, name: String, rssi: Int){
            self.currMessurement = 0
            self.latestRssis = Array(repeating: -200, count: 5)
            
            super.init(id: id, uuid: uuid, name: name, room: room, location: location)
            self.addRssi(rssi: rssi)
        }
    
        convenience init(){
            self.init(id: "", uuid: "", location: "", room: Room.init(), name: "", rssi: -200)
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
