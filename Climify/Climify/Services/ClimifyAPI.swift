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

class ClimifyAPI: NSObject {

    private let questionsUrl = "http://climify.compute.dtu.dk/api/questions"
    private let getTokenUrl = "http://climify.compute.dtu.dk/api/users"
    private let feedbackUrl = "http://climify.compute.dtu.dk/api/feedback"
    private let beaconsUrl = "http://climify.compute.dtu.dk/api/beacons"
    private let roomUrl = "http://climify.compute.dtu.dk/api/rooms"
    private let buildingsUrl = "http://climify.compute.dtu.dk/api/buildings"
    private let loginUrl = "http://climify.compute.dtu.dk/api/auth"
    private let scanningUrl = "http://climify.compute.dtu.dk/api/signalmaps"
    
    
    struct Connectivity {
        static let sharedInstance = NetworkReachabilityManager()!
        static var isConnectedToInternet:Bool {
            return self.sharedInstance.isReachable
        }
    }
    
    func getAnsweredQuestions(roomID: String, time: Time, me: Bool, completion: @escaping (_ questions: [(question: String, questionId: String, answeredCount: Int)], _ statusCode: Int) -> Void){
        guard let token = TOKEN else { return }
        let headers: HTTPHeaders = [ "x-auth-token": token]
        
        var user = "all"
        if me {
            user = "me"
        }
     
        let getAnsweredQuestionsUrl = "\(feedbackUrl)/answeredquestions/?room=\(roomID)&user=\(user)&t=\(time.rawValue)"
        var questions: [(question: String, questionId: String, answeredCount: Int)] = []
        AF.request(getAnsweredQuestionsUrl, method: .get, headers: headers).responseJSON{ response in
            guard let statusCode = response.response?.statusCode else { return }
            
            switch response.result {
                case .success(let value) :
                    let json = JSON(value)
                    for element in json {
                        if let questionName = element.1["question"]["value"].string,
                            let questionId = element.1["question"]["_id"].string,
                            let questionCount = element.1["timesAnswered"].int {
                            let question = (question: questionName,questionId: questionId,answeredCount: questionCount)
                            questions.append(question)
                        }
                    } 
                    completion(questions,statusCode)
                case .failure(let error):
                    print("getAnsweredQuestions", error)
                    completion(questions,statusCode)
            }
        }
    }
    
    func getQuestions(currentRoomID: String, completion: @escaping (_ questions: [Question], _ statusCode: Int) -> Void) {
        guard let token = TOKEN else { return }
    
        let headers: HTTPHeaders = [
            "x-auth-token": token,
            "roomId": currentRoomID
        ]
        
        var questions: [Question] = []
        
        AF.request(questionsUrl, method: .get, headers: headers).responseJSON{ response in
            guard let statusCode = response.response?.statusCode else { return }
            
            switch response.result {
            case .success(let value) :
                let json = JSON(value)
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
                completion(questions, statusCode)
            case .failure(let error):
                print("getQuestions", error)
                completion(questions, statusCode)
            }
        }
    }
    
    func getBeacons(completion: @escaping (_ beacons: [Beacon], _ statusCode: Int) -> Void){
        guard let token = TOKEN else { return }
    
        let headers: HTTPHeaders = [ "x-auth-token": token ]
        
        var beacons: [Beacon] = []
        
        AF.request(beaconsUrl, method: .get, headers: headers).responseJSON{ response in
            guard let statusCode = response.response?.statusCode else { return }
            
            switch response.result {
            case .success(let value) :
                let json = JSON(value)
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
                completion(beacons, statusCode)
            case .failure(let error):
                print("getBeacons",error)
                completion(beacons, statusCode)
            }
        }
    }
    
    func getBuildings(completion: @escaping (_ buildings: [Building],_ statusCode: Int) -> Void) {
        guard let token = TOKEN else { return }
        
        let headers: HTTPHeaders = [ "x-auth-token": token ]

        var buildings: [Building] = []
        
        AF.request(buildingsUrl, method: .get, headers: headers).responseJSON{ response in
            guard let statusCode = response.response?.statusCode else { return }
            
            switch response.result {
            case .success(let value) :
                let json = JSON(value)
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
                completion(buildings, statusCode)
            case .failure(let error):
                print("getBuildings",error)
                completion(buildings, statusCode)
            }
        }
    }
    
    func getToken(completion: @escaping (_ statusCode: Int) -> Void){
        
        AF.request(getTokenUrl, method: .post).responseJSON{ response in
            guard let statusCode = response.response?.statusCode else { return }
   
            switch response.result {
            case .success(_) :
                if let token = JSON(response.response?.allHeaderFields as Any)["x-auth-token"].string {
                UserDefaults.standard.set(token, forKey: "x-auth-token")
                completion(statusCode)
                }
            case .failure(let error):
                print("getToken",error)
                completion(statusCode)
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (_ statusCode: Int, _ description: String) -> Void) {
        guard let token = TOKEN else { return }
        let headers: HTTPHeaders = [ "x-auth-token": token ]
        
        var json: [String : Any] = [:]
        json["email"] = email
        json["password"] = password
        
        AF.request(loginUrl, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers).responseString { response in
            guard let statusCode = response.response?.statusCode else { return }
            switch response.result {
            case.success(let value):
                switch statusCode {
                case 200...300:
                    if let token = JSON(response.response?.allHeaderFields as Any)["x-auth-token"].string {
                        UserDefaults.standard.set(token, forKey: "x-auth-token")
                        UserDefaults.standard.set(true, forKey: "isAdmin")
                    }
                default:
                    print("error")
                }
                print(statusCode)
                print()
             
                completion(statusCode, value)
            case.failure(let error):
                print("login",error)
                completion(statusCode, "")
            }
        }
    }
    
    // Change to tuples
    func getFeedback(questionID: String, roomID: String, time: Time, me: Bool, completion: @escaping (_ answers: [(answerOption: String, answerCount: Int)], _ statusCode: Int) -> Void){
        
        guard let token = TOKEN else { return }
        
        let headers: HTTPHeaders = ["x-auth-token": token]
        var user = "all"
        if me {
            user = "me"
        }
        let getFeedbackStatisticsUrl = "\(feedbackUrl)/questionstatistics/\(questionID)/?room=\(roomID)&user=\(user)&t=\(time.rawValue)"
        
        var feedback: [(answerOption: String, answerCount: Int)] = []
        AF.request(getFeedbackStatisticsUrl, method: .get, headers: headers).responseJSON{ response in
            
            guard let statusCode = response.response?.statusCode else { return }
            
            switch response.result {
            case .success(let value) :
                let json = JSON(value)
                for element in json {
                    if let answer = element.1["answer"]["value"].string,
                        let answerCount = element.1["timesAnswered"].int {
                        let answer = (answerOption: answer, answerCount: answerCount)
                        feedback.append(answer)
                    }
                }
                completion(feedback,statusCode)
            case .failure(let error):
                print("getFeedback",error)
                completion(feedback,statusCode)
            }
        }
    }
    
    func postRoom(buildingId: String, name: String,  completion: @escaping (_ statusCode: Int, _ roomId: String) -> Void) {
        guard let token = TOKEN else { return }
        let headers: HTTPHeaders = ["x-auth-token": token]
        var json: [String : Any] = [:]
        json["buildingId"] = buildingId
        json["name"] = name
        
        AF.request(roomUrl, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                
            guard let statusCode = response.response?.statusCode else { return }
            switch response.result {
            case.success(let value):
                let json = JSON(value)
                print(statusCode)
                if let roomId = json["_id"].string {
                    completion(statusCode, roomId)
                } else {
                    completion(400, "")
                }
            case.failure(let error):
                completion(statusCode, "")
                print("postRoom",error)
                
            }
        }
    }
    
    
    func postSignalMap(signalMap: [Any], roomid: String?, buildingId: String?, completion: @escaping (_ statusCode: Int, _ roomId: String) -> Void) {
        
        guard let token = TOKEN else { return }
        
        let headers: HTTPHeaders = ["x-auth-token": token]

        var json: [String : Any] = [:]
        json["beacons"] = signalMap
        if let roomid = roomid {
            json["roomId"] = roomid
        } else if let buildingid = buildingId {
            json["buildingId"] = buildingid
        }
        
        AF.request(scanningUrl, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                
            guard let statusCode = response.response?.statusCode else { return }
            switch response.result {
            case.success(let value):
                let jsonResult = JSON(value)
                if let roomid = jsonResult["room"].string {
                    print(roomid)
                    completion(statusCode, roomid)
                } else {
                    completion(statusCode, "")
                }
            case.failure(let error):
                print("postSignalMap",error)
                completion(statusCode, "")
                
            }
        }
        
    }
    
    func postFeedback(feedback: Feedback, completion: @escaping (_ statusCode: Int) -> Void){
        if let token = feedback.authToken {
            let headers: HTTPHeaders = [ "x-auth-token": token ]
            
            var json: [String : Any] = [:]
            json["roomId"] = feedback.roomID
            json["questionId"] = feedback.questionId
            json["answerId"] = feedback.answerId
            
            AF.request(feedbackUrl, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers)
                .responseString { response in
                    
                guard let statusCode = response.response?.statusCode else { return }
                switch response.result {
                case.success(_):
                    completion(statusCode)
                case.failure(let error):
                    print("postFeedback",error)
                    completion(statusCode)
                }
            }
        }
    }
}

