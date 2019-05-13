//
//  locationEstimator!Test.swift
//  ClimifyTests
//
//  Created by Christian Hjelmslund on 09/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import XCTest
import CoreLocation
@testable import Climify

class locationEstimatorTest: XCTestCase {

    var climifyApi: ClimifyAPIProtocol?
    var locationEstimator: LocationEstimator?
    var room1: Room?
    var room2: Room?
    var room3: Room?
    var building: Building?
    var beacon1: Beacon?
    var beacon2: Beacon?
    var testBeacons: [Beacon]?
    
    let appBeacon = AppBeacon(id: "id1", uuid: "f7826da6-4fa2-4e98-8024-bc5b71e0893b", building: Building(id: "id", name: "building", rooms: nil), name: "beacon")
    let appBeacon1 = AppBeacon(id: "id2", uuid: "f7826da6-4fa2-4e98-8024-bc5b71e08932", building: Building(id: "id", name: "building", rooms: nil), name: "beacon")
    let appBeacon2 = AppBeacon(id: "id3", uuid: "f7826da6-4fa2-4e98-8024-bc5b71e08931", building: Building(id: "id", name: "building", rooms: nil), name: "beacon")
    
    var signalMap: [String: [Double]]?
   
    var testAppBeacons: [AppBeacon]?
    
    override func setUp() {
        climifyApi = MockClimifyAPI()
        locationEstimator = LocationEstimator(api: climifyApi!)
        
        room1 = Room(id: "id1", name: "room1")
        room2 = Room(id: "id2", name: "room2")
        room3 = Room(id: "id3", name: "room3")
        building = Building(id: "id", name: "building", rooms: [room1!, room2!, room3!])
        beacon1 = Beacon(id: "id1", uuid: "f7826da6-4fa2-4e98-8024-bc5b71e0893b", name: "beacon1", building: building!)
        beacon2 = Beacon(id: "id2", uuid: "f7826da6-4fa2-4e98-8024-bc5b71e0893a", name: "beacon2", building: building!)
        testBeacons = [beacon1!,beacon2!]
        testAppBeacons = [appBeacon, appBeacon1, appBeacon2]
        signalMap = ["signals": [-56.8]]
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        locationEstimator!.serverBeacons.removeAll()
        locationEstimator!.beacons.removeAll()
        locationEstimator!.signalMap.removeAll()
    }
    
    func testAddBeacons(){
        XCTAssertEqual(0,locationEstimator!.beacons.count)
        XCTAssertEqual(0,locationEstimator!.serverBeacons.count)
        locationEstimator!.serverBeacons = testBeacons!
        XCTAssertEqual(0,locationEstimator!.beacons.count)
        XCTAssertNotEqual(0,locationEstimator!.serverBeacons.count)
        locationEstimator!.addBeacons()
        XCTAssertNotEqual(0,locationEstimator!.beacons.count)
        
    }
    
    func testFetchBeacons(){
        XCTAssertEqual(0,locationEstimator!.serverBeacons.count)
        XCTAssertEqual(0,locationEstimator!.beacons.count)
        locationEstimator!.fetchBeacons()
        XCTAssertNotEqual(0,locationEstimator!.beacons.count)
        XCTAssertNotEqual(0, locationEstimator!.serverBeacons.count)
    }
    
    func testInitSignalMap(){
        XCTAssertEqual(0,locationEstimator!.signalMap.count)
        locationEstimator!.serverBeacons = testBeacons!
        locationEstimator!.initSignalMap()
        XCTAssertNotEqual(0,locationEstimator!.signalMap.count)
        
        
        XCTAssertTrue( (testBeacons?.contains { $0.uuid == locationEstimator!.signalMap.first?.key})!)
    }
    
    func testInitTimerAddToSignalMapAndAddToSignalMap(){
        XCTAssertNil(locationEstimator!.signalMap.first)
        
        locationEstimator!.serverBeacons = testBeacons!
        locationEstimator!.initSignalMap()
        
        XCTAssertNotNil(locationEstimator!.signalMap.first?.key)
        XCTAssertEqual(locationEstimator!.signalMap["f7826da6-4fa2-4e98-8024-bc5b71e0893b"]!, [])
        
        // This is of course not the optimal test, because in the real location estimator it is an actual time running, but in the mock version I "faked" the timer by just calling addToSignalMap 3 times (e.g. a timer that runs for three seconds)
        
        
        locationEstimator!.addBeacons()
        
        locationEstimator!.beacons.first?.addRssi(rssi: -30)
        locationEstimator!.beacons.first?.addRssi(rssi: -45)
        locationEstimator!.beacons.first?.addRssi(rssi: -60)
        

        locationEstimator!.initTimerAddToSignalMap()
        
//        let firstBeaconAverage = locationEstimator!.beacons.first?.calcAverage()
//        XCTAssertEqual(locationEstimator!.signalMap["f7826da6-4fa2-4e98-8024-bc5b71e0893b"]!.first, firstBeaconAverage)
//
//        locationEstimator!.beacons.first?.addRssi(rssi: -1)
//        locationEstimator!.beacons.first?.addRssi(rssi: -1)
//        locationEstimator!.beacons.first?.addRssi(rssi: -1)
//        locationEstimator!.addToSignalMap()
//        
//        XCTAssertNotEqual(locationEstimator!.beacons.first?.calcAverage(), firstBeaconAverage)
    }
    
    
    func testGetBeacon(){
        XCTAssertNil(locationEstimator!.getBeacon(id: "1234"))
        locationEstimator!.beacons = testAppBeacons!
        XCTAssertNotNil(locationEstimator!.getBeacon(id: "f7826da6-4fa2-4e98-8024-bc5b71e0893b"))
    }
    
    func testConvertSignalMap(){
        locationEstimator!.beacons = testAppBeacons!
        let serverSignalMap = locationEstimator!.convertSignalMapToServer(signalMap: signalMap!)
        
        XCTAssertNotNil(serverSignalMap.first)
    }
    
    func testSetupRegions(){
        locationEstimator!.serverBeacons = testBeacons!
        XCTAssertEqual(locationEstimator!.regions,[])
        locationEstimator!.setupRegions()
        XCTAssertNotNil(locationEstimator!.regions.first)
    }
    

    func testStartLocating() {
        XCTAssertEqual(0,locationEstimator!.serverBeacons.count)
        locationEstimator!.startLocating()
        XCTAssertNotEqual(0, locationEstimator!.serverBeacons.count)
    }
    
    func testPostRoom(){
        locationEstimator!.postRoom(roomname: "12345") { error in
            XCTAssertNotNil(error)
        }
        locationEstimator!.buildingId = "12345"
        locationEstimator!.postRoom(roomname: "12345") { error in
            XCTAssertNil(error)
        }
    }
    
    func testPushSignalMap(){
        locationEstimator!.pushSignalMap(roomid: "12345", buildingId: "12345") { room in
            XCTAssertNotNil(room)
            XCTAssertEqual(room?.name, "Rum1")
        }
    }
    
    func testFetchRoom(){
        XCTAssertEqual(locationEstimator!.currentRoomId, "")
        locationEstimator!.buildingId = "12345"
        locationEstimator!.signalMap = signalMap!
        locationEstimator!.beacons = testAppBeacons!
        locationEstimator!.fetchRoom()
        XCTAssertNotEqual(locationEstimator!.currentRoomId, "")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
