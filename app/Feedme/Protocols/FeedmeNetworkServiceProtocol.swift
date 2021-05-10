//
//  FeedmeNetworkServiceProtocol.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 11/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation
import Alamofire

protocol FeedmeNetworkServiceProtocol {
    func postFeedback(feedback: Feedback, completion: @escaping () -> Void, onError: @escaping( _ error: ServiceError) -> Void)
    func sendFeedback(feedback: String, completion:
        @escaping (_ response:Bool, _ error: ServiceError?) -> Void)
    
    func postSignalMap(signalMap: [[String : Any]], roomid: String?, completion: @escaping (_ signalMap: SignalmapWithRoom) -> Void,onError: @escaping( _ error: ServiceError) -> Void)
    func postRoom(buildingId: String, name: String, completion: @escaping (_ roomId: String) -> Void,onError: @escaping( _ error: ServiceError) -> Void)
    func fetchFeedback(questionID: String, roomID: String, time: Time, me: Bool, completion: @escaping (_ answers: [AnsweredFeedback]) -> Void,onError: @escaping( _ error: ServiceError) -> Void)
    func login(email: String, password: String, completion: @escaping (_ error: ServiceError?) -> Void)
    func fetchToken(completion: @escaping (_ error: ServiceError?) -> Void)
    func fetchBuildings(completion: @escaping (_ buildings: [Building]?,_ error: ServiceError?) -> Void)
    func fetchUuid(completion: @escaping (_ uuid: String) -> Void,onError: @escaping( _ error: ServiceError) -> Void)
    func fetchBeacons(completion: @escaping (_ beacons: [Beacon]) -> Void, onError: @escaping( _ error: ServiceError) -> Void)
    func fetchQuestions(currentRoomID: String, completion: @escaping (_ questions: [Question]) -> Void, onError: @escaping( _ error: ServiceError) -> Void)
    func fetchAnsweredQuestions(roomID: String, time: Time, me: Bool, completion: @escaping (_ questions: [AnsweredQuestion]) -> Void, onError: @escaping( _ error: ServiceError) -> Void)
    func refreshToken(completion: @escaping (_ error: ServiceError?) -> Void)
    func requestWithRefresh(url: String, method: HTTPMethod, completion: @escaping (_ response: DataResponse<Any>) -> Void, onError: @escaping (_ error: ServiceError) -> Void)
    func requestWithRefresh(url: String, method: HTTPMethod, parameters: Parameters?, completion: @escaping (_ response: DataResponse<Any>) -> Void, onError: @escaping (_ error: ServiceError) -> Void)
    func requestWithRefresh(url: String, method: HTTPMethod, headers: HTTPHeaders,  completion: @escaping (_ response: DataResponse<Any>) -> Void, onError : @escaping (_ error: ServiceError) -> Void)
    func requestWithRefresh(url: String, method: HTTPMethod,parameters: Parameters?, headers: HTTPHeaders,  completion: @escaping (_ response: DataResponse<Any>) -> Void, onError : @escaping (_ error: ServiceError) -> Void)
}


