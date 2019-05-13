//
//  ClimifyAPI.swift
//  Climify
//
//  Created by Christian Hjelmslund on 07/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import Alamofire

class ClimifyAPI {

    private let baseUrl = "http://climify.compute.dtu.dk/api"
    private let genericErrorMessage: String = "Something went wrong, try again later"
    private let decoder = ClimifyAPIDecoder()
    
    func handleError(response: Any?) -> ServiceError {
        if let response = response as? String {
            return ServiceError.error(description: response)
        } else {
            return  ServiceError.error(description: genericErrorMessage)
        }
    }
    
    
    struct Connectivity {
        static let sharedInstance = NetworkReachabilityManager()!
        static var isConnectedToInternet:Bool {
            return self.sharedInstance.isReachable
        }
    }
    
    func getApi() -> ClimifyAPI {
        return self
    }
}

extension ClimifyAPI: ClimifyAPIProtocol {
    
    func fetchAnsweredQuestions(roomID: String, time: Time, me: Bool, completion: @escaping (_ questions: [AnsweredQuestion]?, _ error: ServiceError?) -> Void){
        
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, handleError(response: genericErrorMessage))
            return
        }
        let headers: HTTPHeaders = [ "x-auth-token": token]
        
        var user = "all"
        if me { user = "me" }
        
        let url = "\(baseUrl)/feedback/answeredquestions/?room=\(roomID)&user=\(user)&t=\(time.rawValue)"
        
        AF.request(url, method: .get, headers: headers).responseJSON{ response in
            if response.response?.statusCode == 200 {
                let answeredQuestions = self.decoder.decodeFetchAnsweredQuestion(data: response.result.value as Any)
                if answeredQuestions.isEmpty {
                    completion(nil, self.handleError(response: response.result.value))
                } else {
                    completion(answeredQuestions, nil)
                }
            } else {
                completion(nil, self.handleError(response: response.result.value))
            }
        }
    }
    
    func fetchQuestions(currentRoomID: String, completion: @escaping (_ questions: [Question]?, _ error: ServiceError?) -> Void) {
        
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, handleError(response: genericErrorMessage))
            return
        }
        
        let headers: HTTPHeaders = [
            "x-auth-token": token,
            "roomId": currentRoomID
        ]
        
        let url = "\(baseUrl)/questions"
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                let questions = self.decoder.decodeFetchQuestions(data: response.result.value as Any)
                
                if questions.isEmpty {
                    completion(nil, self.handleError(response: response.result.value))
                } else {
                    completion(questions, nil)
                }
            } else {
                completion(nil, self.handleError(response: response.result.value))
            }
        }
    }
    
    func fetchBeacons(completion: @escaping (_ beacons: [Beacon]?, _ error: ServiceError?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, handleError(response: genericErrorMessage))
            return
        }
        let headers: HTTPHeaders = [ "x-auth-token": token ]
        
        let url = "\(baseUrl)/beacons"
        AF.request(url, method: .get, headers: headers).responseJSON{ response in
            if response.response?.statusCode == 200 {
                let beacons = self.decoder.decodeFetchBeacons(data: response.result.value as Any)
                
                if beacons.isEmpty {
                    completion(nil, self.handleError(response: response.result.value))
                } else {
                    completion(beacons, nil)
                }
            } else {
                completion(nil, self.handleError(response: response.result.value))
            }
        }
    }
    
    func fetchBuildings(completion: @escaping (_ buildings: [Building]?,_ error: ServiceError?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, handleError(response: genericErrorMessage))
            return
        }
        
        let headers: HTTPHeaders = [ "x-auth-token": token ]
        
        let url = "\(baseUrl)/buildings"
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                let buildings = self.decoder.decodeFetchBuildings(data: response.result.value as Any)
                if buildings.isEmpty {
                    completion(nil, self.handleError(response: response.result))
                } else {
                    completion(buildings, nil)
                }
            } else {
                completion(nil, self.handleError(response: response.result))
            }
        }
    }
    
    func fetchToken(completion: @escaping (_ error: ServiceError?) -> Void){
        let url = "\(baseUrl)/users"
        AF.request(url, method: .post).responseJSON{ response in
            if response.response?.statusCode == 200 {
                if let token = self.decoder.decodeToken(data: response.response?.allHeaderFields as Any) {
                    UserDefaults.standard.set(token, forKey: "x-auth-token")
                    completion(nil)
                } else {
                    completion(self.handleError(response: response.result))
                }
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (_ error: ServiceError?) -> Void) {
        var json: [String : Any] = [:]
        json["email"] = email
        json["password"] = password
        
        let url = "\(baseUrl)/auth"
        AF.request(url, method: .post, parameters: json, encoding: JSONEncoding.default).responseString { response in
            if response.response?.statusCode == 200 {
                if let token = self.decoder.decodeToken(data: response.response?.allHeaderFields as Any) {
                    UserDefaults.standard.set(token, forKey: "x-auth-token")
                    UserDefaults.standard.set(true, forKey: "isAdmin")
                    completion(nil)
                } else {
                    completion(self.handleError(response: response.result.value))
                }
            } else {
                completion(self.handleError(response: response.result.value))
            }
        }
    }

    func fetchFeedback(questionID: String, roomID: String, time: Time, me: Bool, completion: @escaping (_ answers: [AnsweredFeedback]?, _ error: ServiceError?) -> Void){
        
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, handleError(response: genericErrorMessage))
            return
        }
        
        let headers: HTTPHeaders = ["x-auth-token": token]
        var user = "all"
        if me {
            user = "me"
        }
        
        let url = "\(baseUrl)/feedback/questionstatistics/\(questionID)/?room=\(roomID)&user=\(user)&t=\(time.rawValue)"
        
        AF.request(url, method: .get, headers: headers).responseJSON{ response in
            if response.response?.statusCode == 200 {
                let feedback = self.decoder.decodeFetchFeedback(data: response.result.value as Any)
                if feedback.isEmpty {
                    completion(nil, self.handleError(response: response.result))
                } else {
                    completion(feedback, nil)
                }
            } else {
                completion(nil, self.handleError(response: response.result))
            }
        }
    }
    
    func postRoom(buildingId: String, name: String,  completion: @escaping (_ roomId: String?, _ error: ServiceError?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, handleError(response: genericErrorMessage))
            return
        }
        
        let headers: HTTPHeaders = ["x-auth-token": token]
        var json: [String : Any] = [:]
        json["buildingId"] = buildingId
        json["name"] = name
        
        let url = "\(baseUrl)/rooms"
        AF.request(url, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    if let roomId = self.decoder.decodePostRoom(data: response.result.value as Any) {
                        completion(roomId, nil)
                    } else {
                        completion(nil, self.handleError(response: response.result))
                    }
                } else {
                    completion(nil, self.handleError(response: response.result))
                }
        }
    }
    
    
    func postSignalMap(signalMap: [Any], roomid: String?, buildingId: String?, completion: @escaping (_ room: Room?, _ error: ServiceError?) -> Void) {
        
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, handleError(response: genericErrorMessage))
            return
        }
        
        let headers: HTTPHeaders = ["x-auth-token": token]
        
        var json: [String : Any] = [:]
        json["beacons"] = signalMap
        if let roomid = roomid {
            json["roomId"] = roomid
        } else if let buildingid = buildingId {
            json["buildingId"] = buildingid
        }
        let url = "\(baseUrl)/signalmaps"
        AF.request(url, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    if let room = self.decoder.decodePostSignalMap(data:  response.result.value as Any) {
                        completion(room, nil)
                    } else {
                        completion(nil, self.handleError(response: response.result))
                    }
                } else {
                    completion(nil, self.handleError(response: response.result))
                }
        }
    }
    
    
    func postFeedback(feedback: Feedback, completion: @escaping (_ error: ServiceError?) -> Void){
        if let token = feedback.authToken {
            let headers: HTTPHeaders = [ "x-auth-token": token ]
            
            var json: [String : Any] = [:]
            json["roomId"] = feedback.roomID
            json["questionId"] = feedback.questionId
            json["answerId"] = feedback.answerId
            
            let url = "\(baseUrl)/feedback"
            AF.request(url, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers)
                .responseString { response in
                    if response.response?.statusCode == 200 {
                        completion(nil)
                    } else {
                        completion(self.handleError(response: response.result))
                    }
            }
        } else {
            completion(self.handleError(response: self.genericErrorMessage))
        }
    }
}

