//
//  AppBeaconTest.swift
//  FeedmeTests
//
//  Created by Christian Hjelmslund on 11/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import XCTest
@testable import Feedme

class AppBeaconTest: XCTestCase {
    
    let beacon = AppBeacon(_id: "id", uuid: "uuid", building: Building(_id: "id", name: "building", rooms: nil), name: "beacon")
    let beacon1 = AppBeacon(_id: "id", uuid: "uuid", building: Building(_id: "id", name: "building", rooms: nil), name: "beacon")
    let beacon2 = AppBeacon(_id: "id", uuid: "uuid", building: Building(_id: "id", name: "building", rooms: nil), name: "beacon")

    
    func testCalcAverage(){
        
        // When creating the AppBeacon, it will contain 5 rssi's values of -100 as default - therefore test the default value
        XCTAssertEqual(beacon.calcAverage(), -100)
        
        
        beacon.addRssi(rssi: -30)
        beacon.addRssi(rssi: -45)
        beacon.addRssi(rssi: -60)
        beacon.addRssi(rssi: -35)
        beacon.addRssi(rssi: -20)
        
        // (-30-45-60-35-20) = -190 -> -190/5 = -38
        XCTAssertEqual(beacon.calcAverage(), -38)
        
        
        beacon1.addRssi(rssi: -25)
        beacon1.addRssi(rssi: -35)
        beacon1.addRssi(rssi: -130)
        beacon1.addRssi(rssi: 20)
        beacon1.addRssi(rssi: -60)
        // -25-35-130+20-60
        // Everything less than -100 will be discarded and all postive numbers (0 is included) will be discarded.
        // (-25-35-60)/3 = -40
        XCTAssertEqual(beacon1.calcAverage(), -40)
        
        // also test with mixed numbers
        beacon2.addRssi(rssi: 0)
        print(beacon2.calcAverage())
        beacon2.addRssi(rssi: 0)
        print(beacon2.calcAverage())
        beacon2.addRssi(rssi: -130)
        print(beacon2.calcAverage())
        beacon2.addRssi(rssi: -60)
        print(beacon2.calcAverage())
        beacon2.addRssi(rssi: -25)
        // (60-25)/2 = -42.5
        
        XCTAssertEqual(beacon2.calcAverage(), -42.5)
    }
}
