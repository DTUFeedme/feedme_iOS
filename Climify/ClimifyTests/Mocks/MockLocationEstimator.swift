//
//  MockLocationEstimator.swift
//  ClimifyTests
//
//  Created by Christian Hjelmslund on 12/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation
import CoreLocation
@testable import Climify


class MockLocationEstimator {
    
    var shouldReturnError = false
    var api: MockClimifyAPI
    var manager:CLLocationManager = CLLocationManager()
    var regions:[CLBeaconRegion] = []
    var beacons:[AppBeacon] = []
    var serverBeacons:[Beacon] = []
    var signalMap:[String: [Double]] = [:]
    var timerSetup = Timer()
    var timerfetchRoom = Timer()
    var buildingId: String?
    var currentRoomId: String = ""
    var isMappingRoom = false
    
    
    convenience init() {
        self.init(false, api: MockClimifyAPI())
    }
    
    init(_ shouldReturnError: Bool, api: MockClimifyAPI) {
        self.api = api
        self.shouldReturnError = shouldReturnError
    }
}
extension MockLocationEstimator: LocationEstimatorProtocol {
    func initTimerAddToSignalMap() {
        // SIMULATES TIMER
        addToSignalMap()
        addToSignalMap()
        addToSignalMap()
    }
    
    func initTimerfetchRoom() {
        fetchRoom()
    }
    
    
    func startLocating() {
        api.fetchBeacons() { beacons, error in
            print("test")
            if error == nil {
                print("ho")
                print(beacons)
                self.serverBeacons = beacons!
                self.addBeacons()
                self.initSignalMap()
                self.setupRegions()
                self.rangeBeacons()
                if self.isMappingRoom {
                    self.initTimerAddToSignalMap()
                } else {
                    self.initTimerAddToSignalMap()
                    self.initTimerfetchRoom()
                }
            } else {
                print("hey")
            }
        }
    }
    
    
    func fetchBeacons() {
        
    }
    
    func initSignalMap() {
        
    }
    
    func setupRegions() {
        
    }
    
    func rangeBeacons() {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons rangedBeacons: [CLBeacon], in region: CLBeaconRegion) {
        
    }
    
    func scanRoom(rangedBeacon: CLBeacon) {
        
    }
    
    func addToSignalMap() {
        
    }
    
    func fetchRoom() {
        
    }
    
    func postRoom(roomname: String, completion: @escaping (ServiceError?) -> Void) {
        completion(nil)
    }
    
    func pushSignalMap(roomid: String, buildingId: String, completion: @escaping (Room?) -> Void) {
        completion(nil)
    }
    
    func addBeacons() {
    }
    
    func getBeacon(id: String) -> AppBeacon? {
        return nil
    }
    
    
}

 

