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
    func convertSignalMapToServer(signalMap: [String : [Double]]) -> [Any] {
        var serverSignalMap: [Any] = []
        
        for beacon in beacons {
            var beaconDict: [String: Any] = [:]
            beaconDict["beaconId"] = beacon.id
            beaconDict["signals"] = signalMap[beacon.uuid]
            serverSignalMap.append(beaconDict)
        }
        return serverSignalMap
    }
    
    
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
        fetchBeacons()
    }
    
    
    func fetchBeacons() {
        api.fetchBeacons() { beacons, error in
            if error == nil {
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
                return
            }
        }
    }
    
    func initSignalMap() {
        for beacon in serverBeacons {
            signalMap[beacon.uuid] = []
        }
    }
    
    func setupRegions() {
        for beacon in serverBeacons {
            if let uuid = UUID(uuidString: beacon.uuid){
                let name = beacon.name
                let region = CLBeaconRegion(proximityUUID: uuid, identifier: name)
                regions.append(region)
            }
        }
    }
    
    func addToSignalMap() {
        for beacon in beacons {
            if isMappingRoom {
                signalMap[beacon.uuid]?.append(beacon.calcAverage())
            } else {
                signalMap[beacon.uuid]? = [beacon.calcAverage()]
            }
        }
    }
    
    func addBeacons() {
        for beacon in serverBeacons {
            let beacon = AppBeacon(id: beacon.id, uuid: beacon.uuid, building: beacon.building, name: beacon.name)
            beacons.append(beacon)
        }
    }
    
    func getBeacon(id: String) -> AppBeacon? {
        return beacons.first(where: { (element) -> Bool in element.uuid == id.lowercased()})
    }
    
    // Pure BLE related methods, it let's the manager start ranging for nearby beacons, so not really feasible to test
    
    func rangeBeacons() {
        
    }
    
    // Since they are basically the same as in MockClimifyAPI it is not worth testing
    
    func fetchRoom() {
        let serverSignalMap = convertSignalMapToServer(signalMap: signalMap)
        if let buildingId = buildingId {
            if serverSignalMap.isEmpty {
                return
            }
            api.postSignalMap(signalMap: serverSignalMap, roomid: nil, buildingId: buildingId) { room, error in
                if error == nil {
                    self.signalMap.removeAll()
                    self.initSignalMap()
                    if let roomId = room?.id, let roomname = room?.name {
                        self.currentRoomId = roomId
                    }
                } else {
                    print(error?.errorDescription as Any)
                }
            }
        }
    }
    
    
    func postRoom(roomname: String, completion: @escaping (_ error: ServiceError?) -> Void) {
        if let buildingId = buildingId {
            
            api.postRoom(buildingId: buildingId, name: roomname) { roomId, error in
                if error == nil {
                    self.pushSignalMap(roomid: roomId!, buildingId: buildingId) { room in
                        completion(error)
                        self.signalMap.removeAll()
                        self.initSignalMap()
                    }
                } else {
                    completion(error)
                }
            }
        } else {
            completion(ServiceError.error(description: "Something went wrong, try again later"))
        }
    }
    
    
    func pushSignalMap(roomid: String, buildingId: String, completion: @escaping (_ room: Room?) -> Void) {
        let serverSignalMap = convertSignalMapToServer(signalMap: signalMap)
        
        api.postSignalMap(signalMap: serverSignalMap, roomid: nil, buildingId: buildingId) {
            room, error in
            if error == nil {
                completion(room)
            } else {
                print(error?.errorDescription as Any)
            }
        }
    }
}

 

