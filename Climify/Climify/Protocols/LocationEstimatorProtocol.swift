//
//  LocationEstimatorProtocol.swift
//  Climify
//
//  Created by Christian Hjelmslund on 12/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationEstimatorProtocol {
    func startLocating()
    func fetchBeacons()
    func initSignalMap()
    func setupRegions()
    func rangeBeacons()
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    func locationManager(_ manager: CLLocationManager, didRangeBeacons rangedBeacons: [CLBeacon], in region: CLBeaconRegion)
    func scanRoom(rangedBeacon: CLBeacon)
    func addToSignalMap()
    func fetchRoom()
    func postRoom(roomname: String, completion: @escaping (_ error: ServiceError?) -> Void)
    func pushSignalMap(roomid: String, buildingId: String, completion: @escaping (_ room: Room?) -> Void)
    func addBeacons()
    func getBeacon(id: String) -> AppBeacon?
    func initTimerAddToSignalMap()
    func initTimerfetchRoom()
}
