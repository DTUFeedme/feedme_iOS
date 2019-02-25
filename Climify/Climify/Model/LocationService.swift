//
//  LocationService.swift
//  Climify
//
//  Created by Christian Hjelmslund on 25/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    
    var manager:CLLocationManager = CLLocationManager()
    var regions:[CLBeaconRegion] = []
    var beacons:[Beacon] = []
    var nearestBeacon = Beacon(id: "", rssi: -200)
    
    func initLocation(){
        
        setupRegions()
        manager.delegate = self
        manager.requestAlwaysAuthorization()

    }
    
    
    func setupRegions(){
        let uuid1:UUID = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")!
        let uuid2:UUID = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893b")!
//        let major1:CLBeaconMajorValue = 9500
//        let minor1:CLBeaconMinorValue = 28090
        let id1 = "beacon1"
//        let major2:CLBeaconMajorValue = 17929
//        let minor2:CLBeaconMinorValue = 25152
        let id2 = "beacon2"
        
        let region1 = CLBeaconRegion(proximityUUID: uuid1, identifier: id1)
        
        let region2 = CLBeaconRegion(proximityUUID: uuid2, identifier: id2)
        
        regions.append(region1)
        regions.append(region2)
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
            
            if nearestBeacon.id == "" {
                nearestBeacon.id = id
                beacons.append(nearestBeacon)
                print(beacons[0].latestRssis)
                nearestBeacon.addRssi(rssi: rssi)
                
            }
            
            else {
                if let result = beacons.first(where: { (element) -> Bool in element.id == id }) {
                    result.addRssi(rssi: rssi)
                    
                    
                    print("ID: ",nearestBeacon.id)
                    
                    
                    if nearestBeacon.calcAverage() < result.calcAverage() && nearestBeacon.id != id {
                        nearestBeacon = result
                    }
                    
                } else {
                    let newBeacon = Beacon(id: id, rssi: rssi)
                    beacons.append(newBeacon)
                }
            }
        }
    }
}
