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
    private let loginUrl = "climify.compute.dtu.dk/api/auth"
    
    
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
        print(getAnsweredQuestionsUrl)
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
                    print(error)
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
                print(error)
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
                        let location = element.1["location"].string,
                        let uuid = element.1["uuid"].string,
                        let room = element.1["room"].dictionary {
                        
                        if let roomId = room["_id"]?.string, let roomName = room["name"]?.string, let roomLocation = room["location"]?.string{
                            let room = Room(id: roomId, name: roomName, location: roomLocation)
                            let beacon = Beacon(id: id, uuid: uuid, name: name, room: room, location: location)
                            beacons.append(beacon)
                        }
                    }
                }
                completion(beacons, statusCode)
            case .failure(let error):
                print(error)
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
                        let rooms = building.1["rooms"].array {
                        
                        for room in rooms {
                            if let roomId = room["_id"].string,
                                let roomName = room["name"].string {
                                
                                let buildingRoom = Room(id: roomId, name: roomName, location: "irrelevant?")
                                buildingRooms.append(buildingRoom)
                            }
                        }
                        let building = Building(id: nil, name: buildingName, rooms: buildingRooms)
                        buildings.append(building)
                    }
                }
                completion(buildings,statusCode)
            case .failure(let error):
                print(error)
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
                print(error)
                completion(statusCode)
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (_ statusCode: Int) -> Void) {
        guard let token = TOKEN else { return }
        
        let headers: HTTPHeaders = [ "x-auth-token": token ]
        
        var json: [String : Any] = [:]
        json["email"] = email
        json["password"] = password
        
        AF.request(loginUrl, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers).responseString { response in
            guard let statusCode = response.response?.statusCode else { return }
            switch response.result {
            case.success(_):
                completion(statusCode)
            case.failure(let error):
                print(error)
                completion(statusCode)
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
                print(error)
                completion(feedback,statusCode)
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
                    print(error)
                    completion(statusCode)
                }
            }
        }
    }
}

