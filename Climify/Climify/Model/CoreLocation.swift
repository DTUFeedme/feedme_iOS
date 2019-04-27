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
    private var signalCounter = 0
 
    var userChangedRoomDelegate: UserChangedRoomDelegate?
    
   
    func startLocating(){
        getBeacons()
        
        manager.delegate = self
        manager.requestAlwaysAuthorization()
    }

    private func getBeacons(){
        climifyApi.getBeacons() { responseBeacons, statusCode in
            if statusCode == 200 {
                self.serverBeacons = responseBeacons
                self.setupRegions()
                self.rangeBeacons()
            }
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
        getLocationByNearestBeacon(beaconName:  region.identifier, rangedBeacons: rangedBeacons)
//        if let beacon = rangedBeacons.first {
//            
//        }
        
    }
    
    func mapRoom(name: String, rangedBeacon: CLBeacon){
        
        if let beacon = getBeacon(id: rangedBeacon.proximityUUID.uuidString) {
            beacon.addRssi(rssi: rangedBeacon.rssi)
            signalCounter += 1
            
            if signalCounter % 2 == 0 && signalCounter > 10 {
                signalMap[beacon.uuid]?.append(beacon.calcAverage())
                signalCounter = 0
            }
        } else {
            addNewBeacon(id: rangedBeacon.proximityUUID.uuidString, name: name, rssi: rangedBeacon.rssi)
        }
    }
  
    
    func addNewBeacon(id: String, name: String, rssi: Int){
        if let tempBeacon = matchFoundBeaconWithBeaconInSystem(uuid: id, name: name){
            let newBeacon = AppBeacon(id: tempBeacon.id, uuid: tempBeacon.uuid, location: tempBeacon.location, room: tempBeacon.room, name: tempBeacon.name, rssi: rssi)
            beacons.append(newBeacon)
            signalMap[newBeacon.uuid] = [Double(rssi)]
        }
    }
    
    private func matchFoundBeaconWithBeaconInSystem(uuid: String, name: String) -> Beacon? {
        for beacon in serverBeacons {
            if beacon.uuid == uuid.lowercased(){
                return beacon
            }
        }
        return nil
    }
    
    func initNearestBeacon(beaconName: String, id: String, rssi: Int){
        if nearestBeacon.uuid == "" {
            nearestBeacon.uuid = id.lowercased()
            nearestBeacon.name = beaconName
            
            if let tempBeacon = matchFoundBeaconWithBeaconInSystem(uuid: id, name: beaconName){
                nearestBeacon = AppBeacon(id: tempBeacon.id, uuid: tempBeacon.uuid, location: tempBeacon.location, room: tempBeacon.room, name: tempBeacon.name, rssi: rssi)
                
                userChangedRoomDelegate!.userChangedRoom(roomname: nearestBeacon.room.name, roomid: nearestBeacon.room.id)
                beacons.append(nearestBeacon)
            }
        }
    }
    
    func getBeacon(id: String) -> AppBeacon? {
        return beacons.first(where: { (element) -> Bool in element.uuid == id.lowercased()})
    }
    
    
    func getLocationByNearestBeacon(beaconName: String, rangedBeacons: [CLBeacon]){
        
        if let beacon = rangedBeacons.first {
            let rssi = beacon.rssi
            let id = beacon.proximityUUID.uuidString
            
            initNearestBeacon(beaconName: beaconName, id: id, rssi: rssi)
            
            if let beacon = getBeacon(id: id) {
                beacon.addRssi(rssi: rssi)
                if nearestBeacon.calcAverage() < beacon.calcAverage() && nearestBeacon.uuid != id {
                    nearestBeacon = beacon
                    userChangedRoomDelegate!.userChangedRoom(roomname: nearestBeacon.room.name, roomid: nearestBeacon.room.id)
                }
            } else {
                addNewBeacon(id: id, name: beaconName, rssi: rssi)
            }
        }
    }
}

protocol UserChangedRoomDelegate {
    func userChangedRoom(roomname: String, roomid: String)
}


