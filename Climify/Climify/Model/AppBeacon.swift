//
//  Beacon.swift
//  Climify
//
//  Created by Christian Hjelmslund on 25/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class AppBeacon: Beacon {

        private var currMessurement: Int
        private var latestRssis: [Int]
        private var connectionLost: [Int]
    
        init(id: String, uuid: String, location: String, room: Room, name: String, rssi: Int){
            self.currMessurement = 0
            self.latestRssis = Array(repeating: -200, count: 5)
            self.connectionLost = Array(repeating: -200, count: 5)
            
            super.init(id: id, uuid: uuid, name: name, room: room, location: location)
            self.addRssi(rssi: rssi)
        }
    
        convenience init(){
            self.init(id: "", uuid: "", location: "", room: Room.init(), name: "", rssi: -200)
        }
    
        func calcAverage() -> Double {
            return Double(latestRssis.filter{ $0 != -200 }.reduce(0,+))/Double(latestRssis.filter{ $0 != -200 }.count)
        }
        
        func addRssi(rssi: Int){
            
            
            if currMessurement > 4 {
                currMessurement = 0
            }
            if rssi < 0 {
                latestRssis[currMessurement] = rssi
            }
            connectionLost[currMessurement] = rssi
            if (Double(connectionLost.reduce(0,+))/Double(connectionLost.count) == 0) {
                print("Connection lost")
            }
            currMessurement += 1
        }
    
    
}
