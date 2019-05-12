//
//  CoreLocation.swift
//  Climify
//
//  Created by Christian Hjelmslund on 17/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import CoreLocation

class LocationEstimator: NSObject, CLLocationManagerDelegate {
    
    static let sharedInstance = LocationEstimator()
    private var manager:CLLocationManager = CLLocationManager()
    private var regions:[CLBeaconRegion] = []
    private var beacons:[AppBeacon] = []
    private var serverBeacons:[Beacon] = []
    private var signalMap:[String: [Double]] = [:]
    private var timerSetup = Timer()
    private var timerfetchRoom = Timer()
    private var buildingId: String?
    private var currentRoomId: String = ""
    var isMappingRoom = false
    var userChangedRoomDelegate: UserChangedRoomDelegate?
    
    func startLocating(){
        fetchBeacons()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
    }
    
    private func fetchBeacons(){
        ClimifyAPI.sharedInstance.fetchBeacons() { beacons, error in
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
                print(error?.errorDescription as Any)
            }
        }
    }
    
    private override init() {
        
    }
    
    
    // when scanning
    func initTimerAddToSignalMap(){
        timerSetup = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(addToSignalMap), userInfo: nil, repeats: true)
    }
    
    // when wanting to get room location
    func initTimerfetchRoom(){
        timerfetchRoom = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(fetchRoom), userInfo: nil, repeats: true)
    }
    
    
    func stopTimerAddToSignalMap() {
        timerSetup.invalidate()
    }
    
    
    func stopTimerfetchRoom() {
        timerfetchRoom.invalidate()
    }

    private func initSignalMap(){
        for beacon in serverBeacons {
            signalMap[beacon.uuid] = []
        }
    }
    
    private func setupRegions(){
        for beacon in serverBeacons {
            if let uuid = UUID(uuidString: beacon.uuid){
                let name = beacon.name
                let region = CLBeaconRegion(proximityUUID: uuid, identifier: name)
                regions.append(region)
            }
        }
    }
    
    private func rangeBeacons(){
        for region in regions {
            manager.startRangingBeacons(in: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            rangeBeacons()
        case .authorizedWhenInUse:
            rangeBeacons()
        case .notDetermined:
            manager.requestAlwaysAuthorization()
            
        default:
            print("Error")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons rangedBeacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = rangedBeacons.first {
            scanRoom(rangedBeacon: beacon)
        }
    }
    
    
    private func scanRoom(rangedBeacon: CLBeacon){
        if let beacon = getBeacon(id: rangedBeacon.proximityUUID.uuidString) {
            buildingId = beacon.building.id
            
            beacon.addRssi(rssi: rangedBeacon.rssi)
        }
    }
    
    @objc private func addToSignalMap() {
        
        for beacon in beacons {
            if isMappingRoom {
                signalMap[beacon.uuid]?.append(beacon.calcAverage())
            } else {
                signalMap[beacon.uuid]? = [beacon.calcAverage()]
            }
        }
    }
    
    @objc private func fetchRoom() {
        let serverSignalMap = convertSignalMapToServer(signalMap: signalMap)
        if let buildingId = buildingId {
            if serverSignalMap.isEmpty {
                return
            }
            ClimifyAPI.sharedInstance.postSignalMap(signalMap: serverSignalMap, roomid: nil, buildingId: buildingId) { room, error in
                if error == nil {
                    self.signalMap.removeAll()
                    self.initSignalMap()
                    if let roomId = room?.id, let roomname = room?.name {
                        self.currentRoomId = roomId
                        self.userChangedRoomDelegate?.userChangedRoom(roomname: roomname, roomid: roomId)
                    }
                } else {
                    print(error?.errorDescription as Any)
                }
            }
        }
    }
    
    func postRoom(roomname: String, completion: @escaping (_ error: ServiceError?) -> Void) {
        
        if let buildingId = buildingId {
            
            ClimifyAPI.sharedInstance.postRoom(buildingId: buildingId, name: roomname) { roomId, error in
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
    
    private func convertSignalMapToServer(signalMap: [String: [Double]]) -> [Any] {
        var serverSignalMap: [Any] = []
//        print("2. ", signalMap)
        for beacon in beacons {
            var beaconDict: [String: Any] = [:]
            beaconDict["beaconId"] = beacon.id
            beaconDict["signals"] = signalMap[beacon.uuid]
            serverSignalMap.append(beaconDict)
        }
//        print("3. ", serverSignalMap)
        return serverSignalMap
    }
    
    
    private func pushSignalMap(roomid: String, buildingId: String, completion: @escaping (_ room: Room?) -> Void) {

        let serverSignalMap = convertSignalMapToServer(signalMap: signalMap)
        ClimifyAPI.sharedInstance.postSignalMap(signalMap: serverSignalMap, roomid: roomid, buildingId: buildingId) {
            room, error in
            if error == nil {
                completion(room)
            } else {
                print(error?.errorDescription as Any)
            }
        }
    }
    
    private func addBeacons(){
        for beacon in serverBeacons {
            let beacon = AppBeacon(id: beacon.id, uuid: beacon.uuid, building: beacon.building, name: beacon.name)
            beacons.append(beacon)
        }
    }
    
    private func getBeacon(id: String) -> AppBeacon? {
        return beacons.first(where: { (element) -> Bool in element.uuid == id.lowercased()})
    }
}

protocol UserChangedRoomDelegate {
    func userChangedRoom(roomname: String, roomid: String)
}

