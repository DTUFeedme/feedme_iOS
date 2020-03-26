//
//  FeedmeNetworkServiceProtocol.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 11/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation

protocol FeedmeNetworkServiceProtocol {
    func postFeedback(feedback: Feedback, completion: @escaping (_ error: ServiceError?) -> Void)
    func postSignalMap(signalMap: [[String : Any]], roomid: String?, buildingId: String?, completion: @escaping (_ room: Room?, _ error: ServiceError?) -> Void)
    func postRoom(buildingId: String, name: String,  completion: @escaping (_ roomId: String?, _ error: ServiceError?) -> Void)
    func fetchFeedback(questionID: String, roomID: String, time: Time, me: Bool, completion: @escaping (_ answers: [AnsweredFeedback]?, _ error: ServiceError?) -> Void)
    func login(email: String, password: String, completion: @escaping (_ error: ServiceError?) -> Void)
    func fetchToken(completion: @escaping (_ error: ServiceError?) -> Void)
    func fetchBuildings(completion: @escaping (_ buildings: [Building]?,_ error: ServiceError?) -> Void)
    func fetchBeacons(completion: @escaping (_ beacons: [Beacon]?, _ error: ServiceError?) -> Void)
    func fetchQuestions(currentRoomID: String, completion: @escaping (_ questions: [Question]?, _ error: ServiceError?) -> Void)
    func fetchAnsweredQuestions(roomID: String, time: Time, me: Bool, completion: @escaping (_ questions: [AnsweredQuestion]?, _ error: ServiceError?) -> Void)
}
