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
    var beacons:[Beacon] = []
    var nearestBeacon = Beacon(id: "", rssi: -200, name: "")
    
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
        setupRegions()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
    }
    
    func setupRegions(){
        let uuid1:UUID = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")!
        let uuid2:UUID = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893b")!
        let id1 = "ha2T"
        let id2 = "vIgJ"
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
                nearestBeacon.name = region.identifier
                beacons.append(nearestBeacon)
                nearestBeacon.addRssi(rssi: rssi)
            } else {
                if let result = beacons.first(where: { (element) -> Bool in element.id == id }) {
                    result.addRssi(rssi: rssi)
                    if nearestBeacon.calcAverage() < result.calcAverage() && nearestBeacon.id != id {
                        nearestBeacon = result
                    }
                    updateLabels()
                } else {
                    let newBeacon = Beacon(id: id, rssi: rssi, name: region.identifier)
                    beacons.append(newBeacon)
                }
            }
        }
    }
}

