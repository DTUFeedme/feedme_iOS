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

    var manager:CLLocationManager = CLLocationManager()
    var regions:[CLBeaconRegion] = []
    var beacons:[AppBeacon] = []
    var serverBeacons:[Beacon] = []
    var nearestBeacon = AppBeacon()
    let networkService = NetworkService()
    var userChangedDelegate: UserChangedRoomDelegate?
    
    func startLocating(){
        getBeacons()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
    }
    
    func getBeacons(){
        networkService.getBeacons() { responseBeacons, statusCode in
            if statusCode == 200 {
                self.serverBeacons = responseBeacons
                self.setupRegions()
                self.rangeBeacons()
            }
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
        
        if status == .authorizedAlways {
            rangeBeacons()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons rangedBeacons: [CLBeacon], in region: CLBeaconRegion) {
        
        if let beacon = rangedBeacons.first {
            let rssi = beacon.rssi
            let id = beacon.proximityUUID.uuidString
            
            if nearestBeacon.uuid == "" {
                nearestBeacon.uuid = id.lowercased()
                nearestBeacon.name = region.identifier
                
                if let tempBeacon = matchFoundBeaconWithBeaconInSystem(uuid: id, name: region.identifier){
                    nearestBeacon = AppBeacon(id: tempBeacon.id, uuid: tempBeacon.uuid, location: tempBeacon.location, room: tempBeacon.room, name: tempBeacon.name, rssi: rssi)
               
                    userChangedDelegate!.userChangedRoom(roomname: nearestBeacon.room.name, roomid: nearestBeacon.room.id)
                
                    beacons.append(nearestBeacon)
                }
            } else {
                if let result = beacons.first(where: { (element) -> Bool in element.uuid == id.lowercased() }
                    ) {
                    result.addRssi(rssi: rssi)
                    if nearestBeacon.calcAverage() < result.calcAverage() && nearestBeacon.uuid != id {
                        nearestBeacon = result
                    
                    userChangedDelegate!.userChangedRoom(roomname: nearestBeacon.room.name, roomid: nearestBeacon.room.id)

                    }
                } else {
                    
                    if let tempBeacon = matchFoundBeaconWithBeaconInSystem(uuid: id, name: region.identifier){
                        
                        let newBeacon = AppBeacon(id: tempBeacon.id, uuid: tempBeacon.uuid, location: tempBeacon.location, room: tempBeacon.room, name: tempBeacon.name, rssi: rssi)
                        beacons.append(newBeacon)
                    }
                }
            }
        }
    }
    
    func matchFoundBeaconWithBeaconInSystem(uuid: String, name: String) -> Beacon? {
        for beacon in serverBeacons{
            if beacon.uuid == uuid.lowercased() {
                return beacon
            }
        }
        return nil
    }
}

protocol UserChangedRoomDelegate {
    func userChangedRoom(roomname: String, roomid: String)
}


