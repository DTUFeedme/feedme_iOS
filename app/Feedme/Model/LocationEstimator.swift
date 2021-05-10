//
//  CoreLocation.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 17/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class LocationEstimator: NSObject, CLLocationManagerDelegate {
    
    var manager:CLLocationManager = CLLocationManager()
    var regions:[CLBeaconRegion] = []
    var region: CLBeaconRegion?
    var beacons:[AppBeacon] = []
    var serverBeacons:[Beacon] = []
    var signalMap:[String: Double] = [:]
    var timerSetup = Timer()
    var timerfetchRoom = Timer()
    var currentRoomId: String = ""
    var isBluetoothOn = false
    var isMappingRoom = false
    var userChangedRoomDelegate: FoundNewRoomProtocol?
    var feedmeNS: FeedmeNetworkServiceProtocol
    var scanningRoomId: String = ""
    var demo = false
    var uuid : String?
    var buildingId: String?
    
    init(service: FeedmeNetworkServiceProtocol) {
        self.feedmeNS = service
    }
    
    func startLocating(){
        feedmeNS.fetchUuid(completion: {uuid in
            self.uuid = uuid
            self.initSignalMap()
            self.setupRegions()
            self.rangeBeacons()
            if self.isMappingRoom {
                self.initTimerAddToSignalMap()
            } else {
                self.initTimerAddToSignalMap()
                self.initTimerfetchRoom()
            }
            self.manager.delegate = self
            self.manager.requestAlwaysAuthorization()
            
        }, onError: {error in
            print(error.errorDescription)
        })
        
    }
    
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        switch central.state {
//        case .poweredOn:
//            print("powered on")
//            isBluetoothOn = true
//            break
//        case .poweredOff:
//            print("powered off")
//            isBluetoothOn = false
//            break
//        case .resetting:
//            break
//        case .unauthorized:
//            break
//        case .unsupported:
//            break
//        case .unknown:
//            break
//        default:
//            break
//        }
//    }
//    func fetchBeacons(){
//        feedmeNS.fetchBeacons() { beacons, error in
//            if error?.errorDescription == "401" {
//                self.feedmeNS.refreshToken { (error) in
//                    self.feedmeNS.fetchBeacons { (beacons, error) in
//                        if error == nil {
//                            self.serverBeacons = beacons!
//                            //self.addBeacons()
//                            self.initSignalMap()
//                            self.setupRegions()
//                            self.rangeBeacons()
//                        } else {
//                            print(error.debugDescription)
//                            return
//                        }
//                    }
//                }
//            } else if error != nil {
//                print(error.debugDescription)
//                print("error in fetching beacnos")
//                return
//            } else {
//                self.serverBeacons = beacons!
//                self.addBeacons()
//                self.initSignalMap()
//                self.setupRegions()
//                self.rangeBeacons()
//            }
//
//
////            if self.isMappingRoom {
////                self.initTimerAddToSignalMap()
////            } else {
////                self.initTimerAddToSignalMap()
////                self.initTimerfetchRoom()
////            }
//        }
//
//
//    }
    
    // when scanning
    func initTimerAddToSignalMap(){
        print("initialized")
        
        if !timerSetup.isValid {
            timerSetup = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(addToSignalMap), userInfo: nil, repeats: true)
        }
    }
    
    // when wanting to get room location
    func initTimerfetchRoom(){
        print("init timer fetch room ")
        if !timerfetchRoom.isValid{
            timerfetchRoom = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(fetchRoom), userInfo: nil, repeats: true)
        }
        
    }
    
    
    func stopTimerAddToSignalMap() {
        print("stopped")
        timerSetup.invalidate()
    }
    
    
    func stopTimerfetchRoom() {
        timerfetchRoom.invalidate()
    }

    func initSignalMap(){
        for beacon in serverBeacons {
            signalMap[beacon.uuid] = -100.0
         }
    }
    
    func setupRegions(){
        
        if let uuid = UUID(uuidString: self.uuid!) {
            region = CLBeaconRegion(proximityUUID: uuid, identifier: "")
        }
        
//        for beacon in serverBeacons {
//            if let uuid = UUID(uuidString: beacon.uuid){
//                let name = beacon.name
//                let region = CLBeaconRegion(proximityUUID: uuid, identifier: name)
//                regions.append(region)
//            }
//        }
    }
    
    func rangeBeacons(){
        manager.startMonitoring(for: region!)
        manager.startRangingBeacons(in: region!)
//
//        for region in regions {
//            manager.startMonitoring(for: region)
//            manager.startRangingBeacons(in: region)
//        }
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
    
//    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
//        <#code#>
//    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons rangedBeacons: [CLBeacon], in region: CLBeaconRegion) {
//        print("called")

//        print(String(rangedBeacons.count))
        print("Scanning")
        for beacon in rangedBeacons {
            print(beacon.description)
            scanRoom(rangedBeacon: beacon)
        }
        
//        if let beacon = rangedBeacons.first {
//            scanRoom(rangedBeacon: beacon)
//        }
    }
    

    @available(iOS 13.0, *)
    func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        print("some error occured \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("some error occured didFailWithError \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("some error occured rangingBeaconsDidFailFor \(error.localizedDescription)")
    }
    
    func scanRoom(rangedBeacon: CLBeacon){
        let beaconName = rangedBeacon.major.stringValue + " - " + rangedBeacon.minor.stringValue
        if let beacon = beacons.first(where: {appBeacon in
            appBeacon.name == beaconName
        }) {
            beacon.addRssi(rssi: rangedBeacon.rssi)
        } else {
            let appBeacon = AppBeacon(uuid: self.uuid!, name: beaconName)
            appBeacon.addRssi(rssi: rangedBeacon.rssi)
            print("added beacon")
            beacons.append(appBeacon)
        }
        
//        if let beacon = getBeacon(id: rangedBeacon.proximityUUID.uuidString) {
//            buildingId = beacon.building
//            beacon.addRssi(rssi: rangedBeacon.rssi)
//        } else {
//            print("beacon not found")
//        }
        
//        var beacon = beacons.first(where: { (b ) -> Bool in
//            b.uuid == rangedBeacon.proximityUUID.uuidString.lowercased()
//        })
//
//        if (beacon == nil) {
//            let beaconName = rangedBeacon.major.stringValue + " - " + rangedBeacon.minor.stringValue
//            beacon = AppBeacon(uuid: rangedBeacon.proximityUUID.uuidString, name: beaconName)
//            beacons.append(beacon!)
//            signalMap[beacon!.uuid] = []
//
//            if let uuid = UUID(uuidString: beacon!.uuid){
//                let name = beacon!.name
//                let region = CLBeaconRegion(proximityUUID: uuid, identifier: name)
//                regions.append(region)
//            }
//
//        }
//        beacon?.addRssi(rssi: rangedBeacon.rssi)
    }
    
    @objc func addToSignalMap() {
        print("adding to signalmap")
        for beacon in beacons {
//            if isMappingRoom {
//                 signalMap[beacon.name]?.append(beacon.calcAverage())
//            } else {
////                print("calledd")
////                print(String(beacon.calcAverage()))
                signalMap[beacon.name] = beacon.calcAverage()
//                signalMap[beacon.uuid]? = beacon.calcAverage()
                
//            }
        }
        
        // Send scanning to room
        if isMappingRoom && !scanningRoomId.isEmpty {
            pushSignalMap(roomid: scanningRoomId, buildingId: "") { (room) in
                print("yay")
            }
        }
        
    }
    
    @objc func fetchRoom() {
        let serverSignalMap = convertSignalMapToServer(signalMap: signalMap)
        
        print("gets here");
        
        if serverSignalMap.isEmpty && !demo{
            return
        }
        
        print(signalMap)
        
        print(serverSignalMap)
        
        feedmeNS.postSignalMap(signalMap: serverSignalMap, roomid: nil, completion: { signalMap in
            self.signalMap.removeAll()
            self.initSignalMap()
            self.currentRoomId = signalMap.room._id
            let roomName = signalMap.room.name
            self.userChangedRoomDelegate?.userChangedRoom(roomname: roomName, roomid: self.currentRoomId)
    
        }, onError: { error in
            // TODO: What should happen here?
            print(error)
        })
    }
    
    func postRoom(roomname: String, completion: @escaping (_ error: ServiceError?) -> Void) {
        if let buildingId = buildingId {
            feedmeNS.postRoom(buildingId: buildingId, name: roomname, completion: {roomId in
                self.scanningRoomId = roomId
                completion(nil)
            }, onError: { error in
                completion(error)
            })
        } else {
            completion(ServiceError.error(description: "Something went wrong, try again later"))
        }
    }
    
    
    
    func convertSignalMapToServer(signalMap: [String: Double]) -> [[String: Any]] {
        var serverSignalMap: [[String: Any]] = []

        dump(signalMap)
        for beacon in beacons {
            var beaconDict: [String: Any] = [:]
            
            beaconDict["name"] = beacon.name
            beaconDict["signal"] = signalMap[beacon.name]
            
            // print(String(signalMap[beacon.name]!))
            serverSignalMap.append(beaconDict)
        }
        return serverSignalMap
    }
    
    
    func pushSignalMap(roomid: String, buildingId: String, completion: @escaping (_ signalMap: SignalmapWithRoom?) -> Void) {
        
        print("what")
        let serverSignalMap = convertSignalMapToServer(signalMap: signalMap)
        feedmeNS.postSignalMap(signalMap: serverSignalMap, roomid: roomid, completion: {
            signalMap in
            completion(signalMap)
        }, onError: { error in
            completion(nil)
        })
    }
}
