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
    
    private var requestSent = false
    private var isMappingRoom = false
    var timer = Timer()
    
    
 
    var userChangedRoomDelegate: UserChangedRoomDelegate?
    
    func startLocating(){
        getBeacons()

        manager.delegate = self
        manager.requestAlwaysAuthorization()
    }
    
    func initTimer(){
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector:#selector(addToSignalMap), userInfo: nil, repeats: true)
    }

    private func getBeacons(){
        climifyApi.getBeacons() { responseBeacons, statusCode in
            if statusCode == 200 {
                self.serverBeacons = responseBeacons
                self.addBeacons()
                self.initSignalMap()
                self.setupRegions()
                self.rangeBeacons()
                self.initTimer()
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
            beacon.addRssi(rssi: rangedBeacon.rssi)
        }
    }
    
    @objc func addToSignalMap() {
        
        for beacon in beacons {
            signalMap[beacon.uuid]?.append(beacon.calcAverage())
        }
        
        print(signalMap)
//
//        var maxLength = getArrayLength()
//
//        for beacon in signalMap {
//            if beacon.value.count < maxLength {
//                signalMap[beacon.key]?.append(-100)
//            }
//        }
//        print(signalMap)
    }
    
    func getArrayLength() -> Int {
        var maxLength = 0
        for beacon in signalMap {
            if beacon.value.count > maxLength {
                maxLength = beacon.value.count
            }
        }
        return maxLength
    }
    
    
    
    
    
    
//    var serverSignalMap:[Any] = []
//    for beacon in beacons {
//    var beaconDict: [String: Any] = [:]
//    beaconDict["beaconId"] = beacon.id
//    beaconDict["signals"] = signalMap[beacon.uuid]
//    serverSignalMap.append(beaconDict)
//    }
//
//    counter+=1
//    if (requestSent == false ) {
//    if isMappingRoom {
//    // Send et post room request først - så smid resultatet af room Id ind før at det virker
//    // BUTTON CLICKED ->
//    climifyApi.postSignalMap(signalMap: serverSignalMap, roomId: "5cc6e79d032e5567cf4e31d4", buildingId: nil) { statusCode, roomId in
//    print("code: ",statusCode, " room: ",roomId)
//    }
//    requestSent = true
//    } else {
//    // Smid beacons building id ind i stedet for hardcoded buildingId
//    climifyApi.postSignalMap(signalMap: serverSignalMap, roomId: nil, buildingId: "5cc6ccdf785ba2674dbc7481") { statusCode, roomId in
//    print("code: ",statusCode, " room: ",roomId)
//    }
//    requestSent = true
//    }
//    }
    
    func addBeacons(){
        for beacon in serverBeacons {
            let beacon = AppBeacon(id: beacon.id, uuid: beacon.uuid, building: beacon.building, name: beacon.name)
            beacons.append(beacon)
        }
        print(beacons)
        
    }
    
//    private func matchFoundBeaconWithBeaconInSystem(uuid: String, name: String) -> Beacon? {
//        for beacon in serverBeacons {
//            if beacon.uuid == uuid.lowercased(){
//                return beacon
//            }
//        }
//        return nil
//    }
    
    
    func getBeacon(id: String) -> AppBeacon? {
        return beacons.first(where: { (element) -> Bool in element.uuid == id.lowercased()})
    }
    
    

    // LEGACY CODE
//
//    func initNearestBeacon(beaconName: String, id: String, rssi: Int){
//        if nearestBeacon.uuid == "" {
//            nearestBeacon.uuid = id.lowercased()
//            nearestBeacon.name = beaconName
//
//            if let tempBeacon = matchFoundBeaconWithBeaconInSystem(uuid: id, name: beaconName){
//                nearestBeacon = AppBeacon(id: tempBeacon.id, uuid: tempBeacon.uuid, building: tempBeacon.building, name: tempBeacon.name, rssi: rssi)
//
//                //                userChangedRoomDelegate!.userChangedRoom(roomname: nearestBeacon.room.name, roomid: nearestBeacon.room.id)
//                beacons.append(nearestBeacon)
//            }
//        }
//    }
//    func getLocationByNearestBeacon(beaconName: String, rangedBeacons: [CLBeacon]){
//
//        if let beacon = rangedBeacons.first {
//            let rssi = beacon.rssi
//            let id = beacon.proximityUUID.uuidString
//
//            initNearestBeacon(beaconName: beaconName, id: id, rssi: rssi)
//
//            if let beacon = getBeacon(id: id) {
//                beacon.addRssi(rssi: rssi)
//                if nearestBeacon.calcAverage() < beacon.calcAverage() && nearestBeacon.uuid != id {
//                    nearestBeacon = beacon
////                    userChangedRoomDelegate!.userChangedRoom(roomname: nearestBeacon.room.name, roomid: nearestBeacon.room.id)
//                }
//            } else {
//                addNewBeacon(id: id, name: beaconName, rssi: rssi)
//            }
//        }
//    }
}

protocol UserChangedRoomDelegate {
    func userChangedRoom(roomname: String, roomid: String)
}


