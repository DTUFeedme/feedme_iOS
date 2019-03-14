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

    
    
//    let questionsUrl = "http://10.16.99.9:3000/api/questions"
//    let initUserUrl = "http://10.16.99.9:3000/api/users"
//    let feedbackUrl = "http://10.16.99.9:3000/api/feedback"
//    let beaconsUrl = "http://10.16.99.9:3000/api/beacons"
//    let roomUrl = "http://10.16.99.9:3000/api/rooms"
    
    
    var beacons: [Beacon] = []
    
    struct Connectivity {
        static let sharedInstance = NetworkReachabilityManager()!
        static var isConnectedToInternet:Bool {
            return self.sharedInstance.isReachable
        }
    }
    
    func getQuestions(currentRoomID: String, completion: @escaping (_ questions: [Question]) -> Void) {
        
//        let group = DispatchGroup()
//        group.enter()
        
        if let userId = UserDefaults.standard.string(forKey: "userID") {
            let headers: HTTPHeaders = [
                "userId": userId,
                "roomId": currentRoomID
            ]
            var questions: [Question] = []
            AF.request(questionsUrl, method: .get, headers: headers).responseJSON{ response in
                print(currentRoomID)
                print("GET QUESTIONS STATUS: ",String(response.response!.statusCode))
                switch response.result {
                    case .success(let value) :
                        let json = JSON(value)
                        print(json.count)
                        for element in json {
                            if let questionName = element.1["name"].string, let id = element.1["_id"].string {
                                let question = Question(questionID: id, question: questionName)
                                questions.append(question)
                            }
                        }
                    completion(questions)
                case .failure(let error):
//                    group.leave()
                    print(error)
                    return
                }
//                group.leave()
            }
//            group.notify(queue: .main) {
//                print("yooo ", questions.count)
//                completionHandler(questions)
//            }
        }
        
    }
    
    func getBeacons(completionHandler: @escaping (_ beacons: [Beacon]) -> Void){
        
        
        let group = DispatchGroup()
        group.enter()
        
        AF.request(beaconsUrl, method: .get).responseJSON{ response in
            print("GET BEACON STATUS: ",String(response.response!.statusCode))
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
                            self.beacons.append(beacon)
                        }
                    }
                }
            case .failure(let error):
                print(error)
                return
            }
            group.leave()
        }
        group.notify(queue: .main) {
            completionHandler(self.beacons)
        }        
    }
    
    
    func initUser(completionHandler: @escaping (_ result: String) -> Void){

        let group = DispatchGroup()
        group.enter()
        
        AF.request(initUserUrl, method: .post).responseJSON{ response in
            switch response.result {
                case .success(let value) :
                   if let id = JSON(value)["_id"].string {
                   UserDefaults.standard.set(id, forKey: "userID")
                   group.leave()
                   group.notify(queue: .main) { completionHandler("success") }
                   }
                case .failure(let error):
                    group.leave()
                    group.notify(queue: .main) { completionHandler("failure") }
                    print(error)
            }
        }
    }
    
    func postFeedback(feedback: Feedback){
        
            //
            var json: [String : Any] = [:]
            json["roomId"] = feedback.roomID
            if let userId = feedback.userID {
                let headers: HTTPHeaders = [
                    "userId": userId
                ]
            

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
                    print(String(response.response!.statusCode))
                    switch response.result {
                    case.success(_):
                        print(response)
                    case.failure(let error):
                        print(error)
                }
            }
        }
    }
}
