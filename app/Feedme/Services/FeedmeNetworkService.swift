//
//  FeedmeNetworkService.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 07/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import Alamofire

class FeedmeNetworkService {

    private let baseUrl = "https://feedme.compute.dtu.dk/api-dev"
    private let genericErrorMessage = "Something went wrong, try again later"
    private let tokenErrorMessage = "Couldn't find user token"
    private let decoder = FeedmeNetworkServiceDecoder()
    
    struct Connectivity {
        static let sharedInstance = NetworkReachabilityManager()!
        static var isConnectedToInternet:Bool {
            return self.sharedInstance.isReachable
        }
    }
    
    func getNetworkJsonResponse(response: Data?) -> String {
        if let data = response {
            return String(data: data, encoding: String.Encoding.utf8) ?? genericErrorMessage
        } else {
            return genericErrorMessage
        }
    }
}

extension FeedmeNetworkService: FeedmeNetworkServiceProtocol {
    
    func fetchAnsweredQuestions(roomID: String, time: Time, me: Bool, completion: @escaping (_ questions: [AnsweredQuestion]?, _ error: ServiceError?) -> Void){
        
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, ServiceError.error(description: tokenErrorMessage))
            return
        }
        let headers: HTTPHeaders = ["x-auth-token": token]
        
        var user = "all"
        if me { user = "me" }
        
        let url = "\(baseUrl)/feedback/answeredquestions/?room=\(roomID)&user=\(user)&t=\(time.rawValue)"
        
        AF.request(url, method: .get, headers: headers).responseJSON{ response in
            if response.response?.statusCode == 200 {
                let answeredQuestions = self.decoder.decodeFetchAnsweredQuestion(data: response.data)
                if answeredQuestions.isEmpty {
                    completion(nil, ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
                } else {
                    completion(answeredQuestions, nil)
                }
            } else {
                completion(nil, ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            }
        }
    }
    
    func refreshToken(completion:
                            @escaping (_ error: ServiceError?) -> Void) {
        
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(ServiceError.error(description: tokenErrorMessage))
            return
        }
        
        guard let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") else {
            completion(ServiceError.error(description: tokenErrorMessage))
            return
        }
        
        var json: [String : Any] = [:]
        json["refreshToken"] = refreshToken
        
        let headers: HTTPHeaders = [
            "x-auth-token": token
        ]
        
        let url = "\(baseUrl)/auth/refresh/"
        AF.request(url, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                if let token = response.response?.allHeaderFields["x-auth-token"] {
                    let refreshToken = self.decoder.decodeRefreshToken(data: response.data)
                    UserDefaults.standard.set(token, forKey: "x-auth-token")
                    UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                    completion(nil)
                }
                
            } else {
                completion(ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            }
        }
        
        
    }
    
    func fetchQuestions(currentRoomID: String, completion:
        @escaping (_ questions: [Question]?, _ error: ServiceError?) -> Void) {
        
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, ServiceError.error(description: tokenErrorMessage))
            return
        }
        
        let headers: HTTPHeaders = [
            "x-auth-token": token,
            "roomId": currentRoomID
        ]
        
        let url = "\(baseUrl)/questions"
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                let questions = self.decoder.decodeFetchQuestions(data: response.data)
                if questions.isEmpty {
                    completion(nil, ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
                } else {
                    completion(questions, nil)
                }
            } else if response.response?.statusCode == 401 {
                completion(nil, ServiceError.error(description: String(response.response!.statusCode)))
            }else {
                completion(nil, ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            }
        }
    }
    
    func fetchBeacons(completion: @escaping (_ beacons: [Beacon]?, _ error: ServiceError?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, ServiceError.error(description: tokenErrorMessage))
            return
        }
        let headers: HTTPHeaders = [ "x-auth-token": token ]
        
        let url = "\(baseUrl)/beacons"
        AF.request(url, method: .get, headers: headers).responseJSON{ response in
            
            if response.response?.statusCode == 200 {
                let beacons = self.decoder.decodeFetchBeacons(data: response.data)
                
                if beacons.isEmpty {
                    completion(nil, ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
                } else {
                    completion(beacons, nil)
                }
                
            } else if response.response?.statusCode == 401 {
                completion(nil, ServiceError.error(description: String(response.response!.statusCode)))
            } else {
                completion(nil, ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            }
        }
        
        
    }
    
    func fetchBuildings(completion: @escaping (_ buildings: [Building]?,_ error: ServiceError?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, ServiceError.error(description: tokenErrorMessage))
            return
        }
        
        let headers: HTTPHeaders = [ "x-auth-token": token ]
        
        let url = "\(baseUrl)/buildings?feedback=me"
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                let buildings = self.decoder.decodeFetchBuildings(data: response.data)
          
                
                if buildings.isEmpty {
                    completion(nil, ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
                } else {
                    completion(buildings, nil)
                }
            } else {
                completion(nil, ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            }
        }
    }
    
    func fetchToken(completion: @escaping (_ error: ServiceError?) -> Void){
        let url = "\(baseUrl)/users/"
        
        AF.request(url, method: .post).responseJSON{ response in
            if response.response?.statusCode == 200 {
                if let token = response.response?.allHeaderFields["x-auth-token"] {
                    let refreshToken = self.decoder.decodeRefreshToken(data: response.data)
            
                    UserDefaults.standard.set(token, forKey: "x-auth-token")
                    UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                    
                    completion(nil)
                } else {
                    completion(ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
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
                if let token = response.response?.allHeaderFields["x-auth-token"] {
                    let refreshToken = self.decoder.decodeRefreshToken(data: response.data)
                    UserDefaults.standard.set(token, forKey: "x-auth-token")
                    UserDefaults.standard.set(true, forKey: "isAdmin")
                    UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                    completion(nil)
                } else {
                    completion(ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
                }
            } else {
                completion(ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            }
        }
    }

    func fetchFeedback(questionID: String, roomID: String, time: Time, me: Bool, completion: @escaping (_ answers: [AnsweredFeedback]?, _ error: ServiceError?) -> Void){
        
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, ServiceError.error(description: tokenErrorMessage))
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
                let feedback = self.decoder.decodeFetchFeedback(data: response.data)
                if feedback.isEmpty {
                    completion(nil, ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
                } else {
                    completion(feedback, nil)
                }
            } else {
                completion(nil, ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            }
        }
    }
    
    func postRoom(buildingId: String, name: String,  completion: @escaping (_ roomId: String?, _ error: ServiceError?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, ServiceError.error(description: tokenErrorMessage))
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
                    if let roomId = self.decoder.decodePostRoom(data: response.data) {
                        completion(roomId, nil)
                    } else {
                        completion(nil, ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
                    }
                } else {
                    completion(nil, ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            }
        }
    }
    
    
    func postSignalMap(signalMap: [[String : Any]], roomid: String?, buildingId: String?, completion: @escaping (_ room: Room?, _ error: ServiceError?) -> Void) {
        
        print("posting signalmap")
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            print("errro")
            print(tokenErrorMessage)
            completion(nil, ServiceError.error(description: tokenErrorMessage))
            return
        }
        
        let headers: HTTPHeaders = ["x-auth-token": token]
        
        var json: [String : Any] = [:]
        json["beacons"] = signalMap
        if let roomid = roomid {
            json["roomId"] = roomid
        } else if let buildingid = buildingId {
//            json["building"] = buildingid
        }
        let url = "\(baseUrl)/signalmaps"
        AF.request(url, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                
            if response.response?.statusCode == 200 {
                if let room = self.decoder.decodePostSignalMap(data: response.data) {
                    completion(room, nil)
                } else {
                    completion(nil, ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
                }
            } else if response.response?.statusCode == 401 {
                completion(nil, ServiceError.error(description: String(response.response!.statusCode)))
            }else {
                print("Sent JSON: ", json)
                completion(nil, ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            }
        }
    }
    
    
    func postFeedback(feedback: Feedback, completion: @escaping (_ error: ServiceError?) -> Void){
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(ServiceError.error(description: tokenErrorMessage))
            return
        }
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
                completion(ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            }
        }
    }
}

