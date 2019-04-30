//
//  CoreLocation.swift
//  Climify
//
//  Created by Christian Hjelmslund on 17/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import CoreLocation

class CoreLocation: NSObject, CLLocationManagerDelegate {
    
    private var manager:CLLocationManager = CLLocationManager()
    private var regions:[CLBeaconRegion] = []
    private var beacons:[AppBeacon] = []
    private var serverBeacons:[Beacon] = []
    private var nearestBeacon = AppBeacon()
    private let climifyApi = ClimifyAPI()
    private var signalMap:[String: [Double]] = [:]
    private var timerSetup = Timer()
    private var timerGetRoom = Timer()
    private var buildingId: String? = nil
    var isMappingRoom = false
    var userChangedRoomDelegate: UserChangedRoomDelegate?
    
    func startLocating(){
        getBeacons()

        manager.delegate = self
        manager.requestAlwaysAuthorization()
    }
    
    // when scanning
    func initTimerAddToSignalMap(){
        timerSetup = Timer.scheduledTimer(timeInterval: 4, target: self, selector:#selector(addToSignalMap), userInfo: nil, repeats: true)
    }
    
    // when wanting to get room location
    func initTimerGetRoom(){
        timerGetRoom = Timer.scheduledTimer(timeInterval: 5, target: self, selector:#selector(getRoom), userInfo: nil, repeats: true)
    }
    
    func stopTimerAddToSignalMap() {
        timerSetup.invalidate()
    }
    
    private func getBeacons(){
        climifyApi.getBeacons() { responseBeacons, statusCode in
            if statusCode == 200 {
                self.serverBeacons = responseBeacons
                self.addBeacons()
                self.initSignalMap()
                self.setupRegions()
                self.rangeBeacons()
                if self.isMappingRoom {
                    self.initTimerAddToSignalMap()
                } else {
                    self.initTimerAddToSignalMap()
                    self.initTimerGetRoom()
                }
            }
        }
    }
    
    func initSignalMap(){
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
        if status == .authorizedAlways {
            rangeBeacons()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons rangedBeacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = rangedBeacons.first {
            scanRoom(name: region.identifier, rangedBeacon: beacon)
        }
    }
    
    
    func scanRoom(name: String, rangedBeacon: CLBeacon){
        if let beacon = getBeacon(id: rangedBeacon.proximityUUID.uuidString) {
            buildingId = beacon.building.id
            beacon.addRssi(rssi: rangedBeacon.rssi)
        }
    }
    
    @objc func addToSignalMap() {
        for beacon in beacons {
            signalMap[beacon.uuid]?.append(beacon.calcAverage())
        }
        
    }
    
    @objc func getRoom() {
        let serverSignalMap = convertSignalMapToServer(signalMap: signalMap)
        if let buildingId = buildingId {
            print(serverSignalMap)
            climifyApi.postSignalMap(signalMap: serverSignalMap, roomid: nil, buildingId: buildingId) { statusCode, roomId in
                print("roomid: ", roomId)
            }
        }
    }
    
    func postRoom(roomname: String) {
        
        if let buildingId = buildingId {
            climifyApi.postRoom(buildingId: buildingId, name: roomname) { statusCode, roomId in
                self.pushSignalMap(roomid: roomId, buildingId: buildingId)
            }
        }
    }
    
    func convertSignalMapToServer(signalMap: [String: [Double]]) -> [Any] {
        var serverSignalMap: [Any] = []
        for beacon in beacons {
            var beaconDict: [String: Any] = [:]
            beaconDict["beaconId"] = beacon.id
            beaconDict["signals"] = signalMap[beacon.uuid]
            serverSignalMap.append(beaconDict)
        }
        return serverSignalMap
    }
   
    
    func pushSignalMap(roomid: String, buildingId: String){
        
        let serverSignalMap = convertSignalMapToServer(signalMap: signalMap)

        climifyApi.postSignalMap(signalMap: serverSignalMap, roomid: roomid, buildingId: buildingId) { statusCode, roomId in
        }
    }
    
    func addBeacons(){
        for beacon in serverBeacons {
            let beacon = AppBeacon(id: beacon.id, uuid: beacon.uuid, building: beacon.building, name: beacon.name)
            beacons.append(beacon)
        }
    }
    
    func getBeacon(id: String) -> AppBeacon? {
        return beacons.first(where: { (element) -> Bool in element.uuid == id.lowercased()})
    }
}

protocol UserChangedRoomDelegate {
    func userChangedRoom(roomname: String, roomid: String)
}


