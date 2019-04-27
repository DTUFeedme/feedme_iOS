//
//  AppBeaconTest.swift
//  ClimifyTests
//
//  Created by Christian Hjelmslund on 11/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import XCTest
@testable import Climify

class AppBeaconTest: XCTestCase {
    
//    let beacon = AppBeacon(id: "id", uuid: "uuid", location: "location", room: Room.init(), name: "name", rssi: 0)
//
//    
//    func testCalcAverage(){
//        
//        // When creating the AppBeacon, it will contain 5 rssi's values of -200 as default - therefore test the default value
//        XCTAssertEqual(beacon.calcAverage(), -200)
//        
//        
//        beacon.latestRssis = [1,2,5,7,10]
//        // 1+2+5+7+10 = 25 -> 25/5 = 5
//        // whole number as a result
//        XCTAssertEqual(beacon.calcAverage(), 5.0)
//        
//        beacon.latestRssis = [1,2,5,7,11]
//        // 1+2+5+7+10 = 25 -> 26/5 = 5.2
//        // fraction as a result
//        XCTAssertEqual(beacon.calcAverage(), 5.2)
//        
//        // also test with mixed numbers
//        beacon.latestRssis = [1,2,-3,5,-17,13]
//        // 1+2-3+5-17+13 = 1 => 1/6 = 0.166 = 0.17
//        
//        XCTAssertEqual(Double(round(100*beacon.calcAverage())/100), 0.17)
//    }
//    
//    func testAddRssi(){
//        
//        // When creating the AppBeacon, in the initializer the first created RSSI value is added to AppBeacon, which means the currMessurement open creation is 1
//        XCTAssertEqual(beacon.currMessurement, 1)
//        beacon.addRssi(rssi: 10)
//        XCTAssertEqual(beacon.currMessurement, 2)
//        
//        // test case where current messurement is > 4, should change to nil and in the end it is
//        // incremented, so should be 1
//        // set currMessurement to 5
//        beacon.currMessurement = 5
//        // add element - currMessurement could be 5+1 => 6, but should be 1.
//        beacon.addRssi(rssi: 10)
//        XCTAssertNotEqual(beacon.currMessurement, 6)
//        XCTAssertEqual(beacon.currMessurement, 1)
//        
//        // test case where rssi is less than zero and see if it is added at the correct spot
//        // since currMessurement increments in the end of the function, we test the case of currMessurement-1
//        beacon.currMessurement = 2
//        beacon.addRssi(rssi: -20)
//        XCTAssertEqual(beacon.latestRssis[beacon.currMessurement-1], -20)
//        
//    }
//    func testThatSuperWorks(){
//        XCTAssertEqual(beacon.id, "id")
//        XCTAssertEqual(beacon.uuid, "uuid")
//        XCTAssertEqual(beacon.location, "location")
////        XCTAssertEqual(beacon.room, room)
//        XCTAssertEqual(beacon.name, "name")
//   
//    }
}
