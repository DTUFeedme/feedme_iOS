//
//  NetworkService.swift
//  Climify
//
//  Created by Christian Hjelmslund on 07/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class NetworkService: NSObject {

    let questionsUrl = "http://192.168.1.102:3000/api/questions"
    let initUserUrl = "http://192.168.1.102:3000/api/users"
    let feedbackUrl = "http://192.168.1.102:3000/api/feedback"
    let beaconsUrl = "http://192.168.1.102:3000/api/beacons"
    let roomUrl = "http://192.168.1.102:3000/api/rooms"
    var statusCode: Int = -1
    
    
//    let questionsUrl = "http://10.16.99.9:3000/api/questions"
//    let initUserUrl = "http://10.16.99.9:3000/api/users"
//    let feedbackUrl = "http://10.16.99.9:3000/api/feedback"
//    let beaconsUrl = "http://10.16.99.9:3000/api/beacons"
//    let roomUrl = "http://10.16.99.9:3000/api/rooms"
    
    
    
    struct Connectivity {
        static let sharedInstance = NetworkReachabilityManager()!
        static var isConnectedToInternet:Bool {
            return self.sharedInstance.isReachable
        }
    }
    
    
    func getQuestions(currentRoomID: String, completion: @escaping (_ questions: [Question], _ statusCode: Int) -> Void) {
        
        if let userId = UserDefaults.standard.string(forKey: "userID") {
            let headers: HTTPHeaders = [
                "userId": userId,
                "roomId": currentRoomID
            ]
            var questions: [Question] = []
            AF.request(questionsUrl, method: .get, headers: headers).responseJSON{ response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch response.result {
                case .success(let value) :
                    let json = JSON(value)
                    for element in json {
                        if let questionName = element.1["name"].string, let id = element.1["_id"].string {
                            let question = Question(questionID: id, question: questionName)
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
    }
    
    func getBeacons(completion: @escaping (_ beacons: [Beacon], _ statusCode: Int) -> Void){
        var beacons: [Beacon] = []
        AF.request(beaconsUrl, method: .get).responseJSON{ response in
            
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
    
    
    func initUser(completion: @escaping (_ statusCode: Int) -> Void){

        AF.request(initUserUrl, method: .post).responseJSON{ response in
            guard let statusCode = response.response?.statusCode else { return }
            switch response.result {
                case .success(let value) :
                   if let id = JSON(value)["_id"].string {
                    UserDefaults.standard.set(id, forKey: "userID")
                    completion(statusCode)
                   }
                case .failure(let error):
                    print(error)
                    completion(statusCode)
            }
        }
    }
    
    func postFeedback(feedback: Feedback, completion: @escaping (_ statusCode: Int) -> Void){
        
        
            if let userId = feedback.userID {
                let headers: HTTPHeaders = [ "userId": userId ]
            
                var json: [String : Any] = [:]
                json["roomId"] = feedback.roomID
                var questions: [[String: Any]] = []

                for elements in feedback.answers {
                    var dict: [String: Any] = [:]
                    dict["_id"] = elements.questionID
                    dict["answer"] = elements.answer as Int
                    questions.append(dict)
                }
                
                json["questions"] = questions
                
                AF.request(feedbackUrl, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers)
                    .responseString { response in
                        guard let statusCode = response.response?.statusCode else { return }
                        switch response.result {
                        case.success(_):
                            print(response.result.value!)
                            completion(statusCode)
                        case.failure(let error):
                            print(error)
                            completion(statusCode)
                    }
                }
            }
    }
}

