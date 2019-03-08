//
//  ViewController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 07/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import CoreLocation

class CoreLocationController: UIViewController, CLLocationManagerDelegate {
    
    var manager:CLLocationManager = CLLocationManager()
    var regions:[CLBeaconRegion] = []
    var beacons:[AppBeacon] = []
    var serverBeacons:[Beacon] = []
    var nearestBeacon = AppBeacon.init()
    let networkService = NetworkService()
    
    @IBOutlet weak var nearestBeaconLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    
    func updateLabels(){
        nearestBeaconLabel.text = nearestBeacon.name
        let rssi = String(nearestBeacon.calcAverage())
        rssiLabel.text = "\(rssi)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        manager.requestAlwaysAuthorization()
        rangeBeacons()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        networkService.getBeacons() { responseBeacons in
            
            self.serverBeacons = responseBeacons
            self.setupRegions()
            self.rangeBeacons()
            
        }
        //setupRegionsOutdated()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
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
        print(rangedBeacons.count)
        if let beacon = rangedBeacons.first {
            
            let rssi = beacon.rssi
            let id = beacon.proximityUUID.uuidString
            
            if nearestBeacon.uuid == "" {
                nearestBeacon.uuid = id.lowercased()
                nearestBeacon.name = region.identifier
                
                if let tempBeacon = matchFoundBeaconWithBeaconInSystem(uuid: id, name: region.identifier){
                    
                    nearestBeacon = AppBeacon(id: tempBeacon.id, uuid: tempBeacon.uuid, location: tempBeacon.location, room: tempBeacon.room, name: tempBeacon.name, rssi: rssi)
                    beacons.append(nearestBeacon)
                }
                

            } else {
                if let result = beacons.first(where: { (element) -> Bool in element.uuid == id.lowercased() }
                    ) {
                    //print(result.name)
                    if result.name == "eRE6"{
                        print("eRE6 RSSI: ",rssi)
                    } else if result.name == "ha2T"{
                        print("ha2T RSSI: ",rssi)
                    } else if result.name == "vIgJ"{
                        print("vIgJ: ",rssi)
                    }
                    result.addRssi(rssi: rssi)
                    if nearestBeacon.calcAverage() < result.calcAverage() && nearestBeacon.uuid != id {
                        nearestBeacon = result
                    }
//                    print()
                    updateLabels()
                } else {
//                     When server works
                    
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
    
    // LEGACY - STILL IN USE
//    func setupRegionsOutdated(){
//        let uuid1:UUID = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")!
//        let uuid2:UUID = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893b")!
//        let id1 = "ha2T"
//        let id2 = "vIgJ"
//        let region1 = CLBeaconRegion(proximityUUID: uuid1, identifier: id1)
//        let region2 = CLBeaconRegion(proximityUUID: uuid2, identifier: id2)
//
//        regions.append(region1)
//        regions.append(region2)
//    }
}

