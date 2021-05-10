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
    let demo = false
    
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
    
    func fetchAnsweredQuestions(roomID: String, time: Time, me: Bool, completion: @escaping (_ questions: [AnsweredQuestion]) -> Void, onError: @escaping( _ error: ServiceError) -> Void){
        
        var user = "all"
        if me { user = "me" }
        
        let url = "\(baseUrl)/feedback/answeredquestions/?room=\(roomID)&user=\(user)&t=\(time.rawValue)"
        
        requestWithRefresh(url: url, method: .get, completion: { response in
            let answeredQuestions = self.decoder.decodeFetchAnsweredQuestion(data: response.data)
            if answeredQuestions.isEmpty {
                onError(ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            } else {
                completion(answeredQuestions)
            }
        
        }, onError: onError)
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
    
    func fetchQuestions(currentRoomID: String, completion: @escaping (_ questions: [Question]) -> Void, onError: @escaping( _ error: ServiceError) -> Void) {
        
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            onError(ServiceError.error(description: tokenErrorMessage))
            return
        }
        
        let headers: HTTPHeaders = [
            "x-auth-token": token,
            "roomId": currentRoomID
        ]
        
        let url = "\(baseUrl)/questions"
        
        requestWithRefresh(url: url, method: .get, headers: headers, completion: { response in
            let questions = self.decoder.decodeFetchQuestions(data: response.data)
            if questions.isEmpty {
                onError(ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            } else {
                completion(questions)
            }
            
        }, onError: onError)
    }
    
  
    func fetchUuid(completion: @escaping (String) -> Void, onError: @escaping (ServiceError) -> Void) {
        let url = "\(baseUrl)/uuids"
        
        requestWithRefresh(url: url, method: .get, completion: { response in
            if let rawData = response.data, let responseMsg = String(data: rawData, encoding: .utf8) {
                completion(responseMsg)
            } else {
                onError(ServiceError.error(description: "Error converting response message"))
            }
        }, onError: onError)
    }
    
    func fetchBeacons(completion: @escaping (_ beacons: [Beacon]) -> Void, onError: @escaping( _ error: ServiceError) -> Void) {
        
        let url = "\(baseUrl)/beacons"
        
        requestWithRefresh(url: url, method: .get, completion: { response in
            let beacons = self.decoder.decodeFetchBeacons(data: response.data)
            if beacons.isEmpty {
                onError(ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            } else {
                completion(beacons)
            }
        }, onError: onError)
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

    func fetchFeedback(questionID: String, roomID: String, time: Time, me: Bool, completion: @escaping (_ answers: [AnsweredFeedback]) -> Void,onError: @escaping( _ error: ServiceError) -> Void){
        
        var user = "all"
        if me {
            user = "me"
        }
        
        let url = "\(baseUrl)/feedback/questionstatistics/\(questionID)/?room=\(roomID)&user=\(user)&t=\(time.rawValue)"
        
        requestWithRefresh(url: url, method: .get, completion: {response in
            let feedback = self.decoder.decodeFetchFeedback(data: response.data)
            if feedback.isEmpty {
                onError(ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            } else {
                completion(feedback)
            }
        }, onError: onError)
    }
    
    func postRoom(buildingId: String, name: String,  completion: @escaping (_ roomId: String) -> Void,onError: @escaping( _ error: ServiceError) -> Void) {
        var json: [String : Any] = [:]
        json["buildingId"] = buildingId
        json["name"] = name
        
        let url = "\(baseUrl)/rooms"
        
        requestWithRefresh(url: url, method: .post, parameters: json, completion: { response in
            if let roomId = self.decoder.decodePostRoom(data: response.data) {
                completion(roomId)
            } else {
                onError( ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            }
        }, onError: onError)
    }
    
    
    func postSignalMap(signalMap: [[String : Any]], roomid: String?, completion: @escaping (_ signalMap: SignalmapWithRoom) -> Void,onError: @escaping( _ error: ServiceError) -> Void) {
        
        var json: [String : Any] = [:]
        json["beacons"] = signalMap
        if let roomid = roomid {
            json["roomId"] = roomid
        }
        
        let url = "\(baseUrl)/signalmaps"
        
        print(json)
        requestWithRefresh(url: url, method: .post, parameters: json, completion: {response in
            if let signalMap = self.decoder.decodePostSignalMap(data: response.data) {
                completion(signalMap)
            } else {
                onError(ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            }
        }, onError: onError)
    }
    
    
    func postFeedback(feedback: Feedback, completion: @escaping () -> Void, onError: @escaping( _ error: ServiceError) -> Void){
        
        var json: [String : Any] = [:]
        json["roomId"] = feedback.roomID
        json["questionId"] = feedback.questionId
        json["answerId"] = feedback.answerId
        
        let url = "\(baseUrl)/feedback"
        
        requestWithRefresh(url: url, method: .post, parameters: json, completion: {response in
            completion()
        }, onError: onError)
    }
    
    func sendFeedback(feedback: String, completion:
        @escaping (_ response:Bool, _ error: ServiceError?) -> Void) {
        
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(false, ServiceError.error(description: tokenErrorMessage))
            return
        }
        
        let headers: HTTPHeaders = [
            "x-auth-token": token
        ]
        
        var json: [String : Any] = [:]
        json["feedback"] = feedback

        print(json)
        
        let url = "\(baseUrl)/app-feedback"
        AF.request(url, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers).responseString { response in
            print(response)
            if response.response?.statusCode == 200 {
//                let questions = self.decoder.decodeFetchQuestions(data: response.data)
//                if questions.isEmpty {
//                    completion(false, ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
//                } else {
                    completion(true, nil)
               // }
            } else if response.response?.statusCode == 401 {
                completion(false, ServiceError.error(description: String(response.response!.statusCode)))
            }else {
                completion(false, ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            }
        }
    }
    
    func requestWithRefresh(url: String, method: HTTPMethod, completion: @escaping (_ response: DataResponse<Any>) -> Void, onError : @escaping (_ error: ServiceError) -> Void) {
        
        requestWithRefresh(url: url, method: method, parameters: nil, completion: completion, onError: onError)
    }
    
    func requestWithRefresh(url: String, method: HTTPMethod, headers: HTTPHeaders, completion: @escaping (_ response: DataResponse<Any>) -> Void, onError : @escaping (_ error: ServiceError) -> Void) {
        
        requestWithRefresh(url: url, method: method, parameters: nil, headers: headers, completion: completion, onError: onError)
    }
    
    
    func requestWithRefresh(url: String, method: HTTPMethod, parameters: Parameters?,  completion: @escaping (_ response: DataResponse<Any>) -> Void, onError : @escaping (_ error: ServiceError) -> Void){
        
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            onError(ServiceError.error(description: tokenErrorMessage))
            return
        }
        
        let headers: HTTPHeaders = [ "x-auth-token": token ];
        
        print("request" )
        print(parameters)
        
        requestWithRefresh(url: url, method: method, parameters: parameters, headers: headers, completion: completion, onError: onError)
    }
    
    func requestWithRefresh(url: String, method: HTTPMethod,parameters: Parameters?, headers: HTTPHeaders,  completion: @escaping (_ response: DataResponse<Any>) -> Void, onError : @escaping (_ error: ServiceError) -> Void) {
        
        print("final params")
        print(parameters)
        AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200{
                completion(response)
            } else if response.response?.statusCode == 401 {
                self.refreshToken { (error) in
                    guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
                        onError(ServiceError.error(description: self.tokenErrorMessage))
                        return
                    }
                    var updatedHeaders: HTTPHeaders = headers
                    updatedHeaders["x-auth-token"] = token
                    
                    AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: updatedHeaders).responseJSON { response in
                        if response.response?.statusCode == 200{
                            completion(response)
                        } else {
                            onError(ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
                        }
                    }
                }
            } else {
                onError(ServiceError.error(description: self.getNetworkJsonResponse(response: response.data)))
            }
        }
    }
}

