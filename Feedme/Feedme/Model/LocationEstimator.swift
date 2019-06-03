//
//  CoreLocation.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 17/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import CoreLocation

class LocationEstimator: NSObject, CLLocationManagerDelegate {
    
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
    var userChangedRoomDelegate: FoundNewRoomProtocol?
    var feedmeNS: FeedmeNetworkServiceProtocol
    
    init(service: FeedmeNetworkServiceProtocol) {
        self.feedmeNS = service
    }
    
    func startLocating(){
        fetchBeacons()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
    }
    
    func fetchBeacons(){
        feedmeNS.fetchBeacons() { beacons, error in
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
            }
        }
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

    func initSignalMap(){
        for beacon in serverBeacons {
            signalMap[beacon.uuid] = []
        }
    }
    
    func setupRegions(){
        for beacon in serverBeacons {
            if let uuid = UUID(uuidString: beacon.uuid){
                let name = beacon.name
                let region = CLBeaconRegion(proximityUUID: uuid, identifier: name)
                regions.append(region)
            }
        }
    }
    
    func rangeBeacons(){
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
    
    
    func scanRoom(rangedBeacon: CLBeacon){
        if let beacon = getBeacon(id: rangedBeacon.proximityUUID.uuidString) {
            buildingId = beacon.building._id
            beacon.addRssi(rssi: rangedBeacon.rssi)
            print(rangedBeacon.rssi)
        }
       
    }
    
    @objc func addToSignalMap() {
        
        for beacon in beacons {
            if isMappingRoom {
                signalMap[beacon.uuid]?.append(beacon.calcAverage())
            } else {
                signalMap[beacon.uuid]? = [beacon.calcAverage()]
            }
        }
    }
    
    @objc func fetchRoom() {
        let serverSignalMap = convertSignalMapToServer(signalMap: signalMap)
        if let buildingId = buildingId {
            if serverSignalMap.isEmpty {
                return
            }
    
            feedmeNS.postSignalMap(signalMap: serverSignalMap, roomid: nil, buildingId: buildingId) { room, error in
                if error == nil {
                    self.signalMap.removeAll()
                    self.initSignalMap()
                    if let roomId = room?._id, let roomname = room?.name {
                        self.currentRoomId = roomId
                        self.userChangedRoomDelegate?.userChangedRoom(roomname: roomname, roomid: roomId)
                    }
                } else {
                    
                }
            }
        }
    }
    
    func postRoom(roomname: String, completion: @escaping (_ error: ServiceError?) -> Void) {
        
        if let buildingId = buildingId {
            
            feedmeNS.postRoom(buildingId: buildingId, name: roomname) { roomId, error in
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
    
    func convertSignalMapToServer(signalMap: [String: [Double]]) -> [[String: Any]] {
        var serverSignalMap: [[String: Any]] = []

        for beacon in beacons {
            var beaconDict: [String: Any] = [:]
            beaconDict["beaconId"] = beacon._id
            beaconDict["signals"] = signalMap[beacon.uuid]
            serverSignalMap.append(beaconDict)
        }
        return serverSignalMap
    }
    
    
    func pushSignalMap(roomid: String, buildingId: String, completion: @escaping (_ room: Room?) -> Void) {

        let serverSignalMap = convertSignalMapToServer(signalMap: signalMap)
        feedmeNS.postSignalMap(signalMap: serverSignalMap, roomid: roomid, buildingId: nil) {
            room, error in
            if error == nil {
                completion(room)
            } else {
//                completion(error)
            }
        }
    }
    
    func addBeacons(){
        for beacon in serverBeacons {
            let beacon = AppBeacon(_id: beacon._id, uuid: beacon.uuid, building: beacon.building, name: beacon.name)
            beacons.append(beacon)
        }
    }
    
    func getBeacon(id: String) -> AppBeacon? {
        return beacons.first(where: { (element) -> Bool in element.uuid == id.lowercased()})
    }
}
