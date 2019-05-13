//
//  LocationEstimatorProtocol.swift
//  Climify
//
//  Created by Christian Hjelmslund on 12/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation

protocol LocationEstimatorProtocol {
    func startLocating()
    func fetchBeacons()
    func initSignalMap()
    func setupRegions()
    func rangeBeacons()
    func addToSignalMap()
    func fetchRoom()
    func postRoom(roomname: String, completion: @escaping (_ error: ServiceError?) -> Void)
    func pushSignalMap(roomid: String, buildingId: String, completion: @escaping (_ room: Room?) -> Void)
    func addBeacons()
    func getBeacon(id: String) -> AppBeacon?
    func initTimerAddToSignalMap()
    func initTimerfetchRoom()
    func convertSignalMapToServer(signalMap: [String: [Double]]) -> [Any]
}

