//
//  ClimifyAPIProtocol.swift
//  Climify
//
//  Created by Christian Hjelmslund on 11/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation

protocol ClimifyAPIProtocol {
    func postFeedback(feedback: Feedback, completion: @escaping (_ error: ServiceError?) -> Void)
//    func postSignalMap(signalMap: [Any], roomid: String?, buildingId: String?, completion: @escaping (_ statusCode: Int, _ room: Room?) -> Void)
//    func postRoom(buildingId: String, name: String,  completion: @escaping (_ statusCode: Int, _ roomId: String) -> Void)
    func fetchFeedback(questionID: String, roomID: String, time: Time, me: Bool, completion: @escaping (_ answers: [(answerOption: String, answerCount: Int)]?, _ error: ServiceError?) -> Void)
    func login(email: String, password: String, completion: @escaping (_ error: ServiceError?) -> Void)
    func fetchToken(completion: @escaping (_ error: ServiceError?) -> Void)
    func fetchBuildings(completion: @escaping (_ buildings: [Building]?,_ error: ServiceError?) -> Void)
    func fetchBeacons(completion: @escaping (_ beacons: [Beacon]?, _ error: ServiceError?) -> Void)
    func fetchQuestions(currentRoomID: String, completion: @escaping (_ questions: [Question]?, _ error: ServiceError?) -> Void)
    func fetchAnsweredQuestions(roomID: String, time: Time, me: Bool, completion: @escaping (_ questions: [(question: String, questionId: String, answeredCount: Int)]?, _ error: ServiceError?) -> Void)
}
