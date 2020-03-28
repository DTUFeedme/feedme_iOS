//
//  locationEstimator!Test.swift
//  FeedmeTests
//
//  Created by Christian Hjelmslund on 09/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import XCTest
import CoreLocation
@testable import Feedme

class LocationEstimatorTest: XCTestCase {

    var feedmeNS: FeedmeNetworkServiceProtocol?
    var locationEstimator: LocationEstimator?
    var room1: Room?
    var room2: Room?
    var room3: Room?
    var building: Building?
    var beacon1: Beacon?
    var beacon2: Beacon?
    var testBeacons: [Beacon]?
    
    let appBeacon = AppBeacon(_id: "id1", uuid: "f7826da6-4fa2-4e98-8024-bc5b71e0893b", building: Building(_id: "id", name: "building", rooms: nil), name: "beacon")
    let appBeacon1 = AppBeacon(_id: "id2", uuid: "f7826da6-4fa2-4e98-8024-bc5b71e08932", building: Building(_id: "id", name: "building", rooms: nil), name: "beacon")
    let appBeacon2 = AppBeacon(_id: "id3", uuid: "f7826da6-4fa2-4e98-8024-bc5b71e08931", building: Building(_id: "id", name: "building", rooms: nil), name: "beacon")
    
    var signalMap: [String: [Double]]?
   
    var testAppBeacons: [AppBeacon]?
    
    override func setUp() {
        feedmeNS = MockFeedmeNetworkService()
        locationEstimator = LocationEstimator(service: feedmeNS!)
        
        room1 = Room(_id: "id1", name: "room1")
        room2 = Room(_id: "id2", name: "room2")
        room3 = Room(_id: "id3", name: "room3")
        building = Building(_id: "id", name: "building", rooms: [room1!, room2!, room3!])
        beacon1 = Beacon(_id: "id1", uuid: "f7826da6-4fa2-4e98-8024-bc5b71e0893b", name: "beacon1", building: building!)
        beacon2 = Beacon(_id: "id2", uuid: "f7826da6-4fa2-4e98-8024-bc5b71e0893a", name: "beacon2", building: building!)
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
        
        locationEstimator!.addBeacons()
        
        locationEstimator!.beacons.first?.addRssi(rssi: -30)
        locationEstimator!.beacons.first?.addRssi(rssi: -45)
        locationEstimator!.beacons.first?.addRssi(rssi: -60)
        


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
}
