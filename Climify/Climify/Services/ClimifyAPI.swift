//
//  ClimifyAPI.swift
//  Climify
//
//  Created by Christian Hjelmslund on 07/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import CoreLocation

class ClimifyAPI {

    private let baseUrl = "http://climify.compute.dtu.dk/api"
    private let genericErrorMessage: String = "Something went wrong, try again later"

    static let sharedInstance = ClimifyAPI()

    private init() {
        
    }
    
    struct Connectivity {
        static let sharedInstance = NetworkReachabilityManager()!
        static var isConnectedToInternet:Bool {
            return self.sharedInstance.isReachable
        }
    }
}

extension ClimifyAPI: ClimifyAPIProtocol {
    
    func fetchAnsweredQuestions(roomID: String, time: Time, me: Bool, completion: @escaping (_ questions: [(question: String, questionId: String, answeredCount: Int)]?, _ error: ServiceError?) -> Void){
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, handleError(response: genericErrorMessage))
            return
        }
        let headers: HTTPHeaders = [ "x-auth-token": token]
        
        var user = "all"
        if me {
            user = "me"
        }
        
        let url = "\(baseUrl)/feedback/answeredquestions/?room=\(roomID)&user=\(user)&t=\(time.rawValue)"
        var questions: [(question: String, questionId: String, answeredCount: Int)] = []
        AF.request(url, method: .get, headers: headers).responseJSON{ response in
            if response.response?.statusCode == 200 {
                let json = JSON(response.result.value as Any)
                for element in json {
                    if let questionName = element.1["question"]["value"].string,
                        let questionId = element.1["question"]["_id"].string,
                        let questionCount = element.1["timesAnswered"].int {
                        let question = (question: questionName,questionId: questionId,answeredCount: questionCount)
                        questions.append(question)
                    }
                }
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
    
    func fetchQuestions(currentRoomID: String, completion: @escaping (_ questions: [Question]?, _ error: ServiceError?) -> Void) {
        
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, handleError(response: genericErrorMessage))
            return
        }
        
        let headers: HTTPHeaders = [
            "x-auth-token": token,
            "roomId": currentRoomID
        ]
        
        var questions: [Question] = []
        let url = "\(baseUrl)/questions"
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                let json = JSON(response.result.value as Any)
                for element in json {
                    if let questionName = element.1["value"].string, let id = element.1["_id"].string, let answersJson = element.1["answerOptions"].array {
                        
                        var answerOptions: [Question.answerOption] = []
                        for element in answersJson {
                            if let answerValue = element["value"].string, let answerID = element["_id"].string {
                                let answerOption = Question.answerOption(id: answerID, value: answerValue)
                                answerOptions.append(answerOption)
                            }
                        }
                        let question = Question(questionID: id, question: questionName, answerOptions: answerOptions)
                        questions.append(question)
                    }
                }
                if questions.isEmpty {
                    completion(nil, ServiceError.error(description: self.genericErrorMessage))
                } else {
                    completion(questions, nil)
                }
            } else {
                if let response = response.result.value as? String {
                    completion(nil, ServiceError.error(description: response))
                } else {
                    completion(nil, ServiceError.error(description: self.genericErrorMessage))
                }
            }
        }
    }
    
    func fetchBeacons(completion: @escaping (_ beacons: [Beacon]?, _ error: ServiceError?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, handleError(response: genericErrorMessage))
            return
        }
        let headers: HTTPHeaders = [ "x-auth-token": token ]
        
        var beacons: [Beacon] = []
        
        let url = "\(baseUrl)/beacons"
        AF.request(url, method: .get, headers: headers).responseJSON{ response in
            if response.response?.statusCode == 200 {
                let json = JSON(response.result.value as Any)
                for element in json {
                    if let name = element.1["name"].string,
                        let id = element.1["_id"].string,
                        let uuid = element.1["uuid"].string,
                        let building = element.1["building"].dictionary {
                        
                        if let buildingId = building["_id"]?.string, let buildingName = building["name"]?.string{
                            let building = Building(id: buildingId, name: buildingName, rooms: nil)
                            let beacon = Beacon(id: id, uuid: uuid, name: name, building: building)
                            beacons.append(beacon)
                        }
                    }
                }
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
    
    
    func handleError(response: Any?) -> ServiceError {
        if let response = response as? String {
            return ServiceError.error(description: response)
        } else {
            return  ServiceError.error(description: genericErrorMessage)
        }
    }
   
    
    func fetchBuildings(completion: @escaping (_ buildings: [Building]?,_ error: ServiceError?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            completion(nil, handleError(response: genericErrorMessage))
            return
        }
        
        let headers: HTTPHeaders = [ "x-auth-token": token ]
        
        var buildings: [Building] = []
        let url = "\(baseUrl)/buildings"
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                let json = JSON(response.result.value as Any)
                for building in json {
                    var buildingRooms: [Room] = []
                    if let buildingName = building.1["name"].string,
                        let buildingId = building.1["_id"].string,
                        let rooms = building.1["rooms"].array {
                        for room in rooms {
                            if let roomId = room["_id"].string,
                                let roomName = room["name"].string {
                                
                                let buildingRoom = Room(id: roomId, name: roomName)
                                buildingRooms.append(buildingRoom)
                            }
                        }
                        let building = Building(id: buildingId, name: buildingName, rooms: buildingRooms)
                        buildings.append(building)
                    }
                }
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
                if let token = JSON(response.response?.allHeaderFields as Any)["x-auth-token"].string {
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
                if let token = JSON(response.response?.allHeaderFields as Any)["x-auth-token"].string {
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
    
    func fetchFeedback(questionID: String, roomID: String, time: Time, me: Bool, completion: @escaping (_ answers: [(answerOption: String, answerCount: Int)]?, _ error: ServiceError?) -> Void){
        
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
        var feedback: [(answerOption: String, answerCount: Int)] = []
        
        AF.request(url, method: .get, headers: headers).responseJSON{ response in
            if response.response?.statusCode == 200 {
                let json = JSON(response.result.value as Any)
                for element in json {
                    if let answer = element.1["answer"]["value"].string,
                        let answerCount = element.1["timesAnswered"].int {
                        let answer = (answerOption: answer, answerCount: answerCount)
                        feedback.append(answer)
                    }
                }
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
    
    func postRoom(buildingId: String, name: String,  completion: @escaping (_ statusCode: Int, _ roomId: String) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
            return
        }
        let headers: HTTPHeaders = ["x-auth-token": token]
        var json: [String : Any] = [:]
        json["buildingId"] = buildingId
        json["name"] = name
        
        let url = "\(baseUrl)/rooms"
        AF.request(url, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                switch response.result {
                case.success(let value):
                    let json = JSON(value)
                    if let roomId = json["_id"].string {
                        completion(statusCode, roomId)
                    } else {
                        completion(statusCode, "")
                    }
                case.failure(let error):
                    completion(statusCode, "")
                    print("postRoom",error)
                    
                }
        }
    }
    
    
    func postSignalMap(signalMap: [Any], roomid: String?, buildingId: String?, completion: @escaping (_ statusCode: Int, _ room: Room?) -> Void) {
        
        guard let token = UserDefaults.standard.string(forKey: "x-auth-token") else {
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
                
                guard let statusCode = response.response?.statusCode else { return }
                switch response.result {
                case.success(let value):
                    let jsonResult = JSON(value)
                    if let room = jsonResult["room"].dictionaryObject {
                        if let id = room["_id"] as? String, let name = room["name"] as? String {
                            let room = Room(id: id, name: name)
                            completion(statusCode, room)
                        } else {
                            completion(statusCode, nil)
                        }
                    } else {
                        completion(statusCode, nil)
                    }
                case.failure(let error):
                    print("postSignalMap",error)
                    completion(statusCode, nil)
                    
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
                        let error = ServiceError.error(description: response.result.value ?? self.genericErrorMessage)
                        completion(error)
                    }
            }
        } else {
            let error = ServiceError.error(description: self.genericErrorMessage)
            completion(error)
        }
    }
}

