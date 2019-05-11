//
//  LocationEstimatorTest.swift
//  ClimifyTests
//
//  Created by Christian Hjelmslund on 09/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import XCTest
@testable import Climify

class LocationEstimatorTest: XCTestCase {
    
    var room1: Room?
    var room2: Room?
    var room3: Room?
    var building: Building?
    var beacon1: Beacon?
    var beacon2: Beacon?
   
    override func setUp() {
        room1 = Room(id: "id1", name: "room1")
        room2 = Room(id: "id2", name: "room2")
        room3 = Room(id: "id3", name: "room3")
        building = Building(id: "id", name: "building", rooms: [room1!, room2!, room3!])
        beacon1 = Beacon(id: "id1", uuid: "uuid1", name: "beacon1", building: building!)
        beacon2 = Beacon(id: "id2", uuid: "uuid2", name: "beacon2", building: building!)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
//        LocationEstimator.sharedInstance.addBeacon
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
