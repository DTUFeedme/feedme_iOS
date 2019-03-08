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

    let questionsUrl = "http://10.123.195.30:3000/api/questions"
    let initUserUrl = "http://10.123.195.30:3000/api/users"
    let feedbackUrl = "http://10.123.195.30:3000/api/feedback"
    let beaconsUrl = "http://10.123.195.30:3000/api/beacons"
    let roomUrl = "http://10.123.195.30:3000/api/rooms"
    
    var questions: [Question] = []
    var beacons: [Beacon] = []
    
    func getQuestions(completionHandler: @escaping (_ questions: [Question]) -> Void) {
        
        let group = DispatchGroup()
        group.enter()
        
        AF.request(questionsUrl, method: .get).responseJSON{ response in
            switch response.result {
                case .success(let value) :
                    let json = JSON(value)
                    
                    for element in json {
                        if let questionName = element.1["name"].string, let id = element.1["_id"].string {
                            let question = Question(questionID: id, question: questionName)
                            self.questions.append(question)
                        }
                    }
            case .failure(let error):
                group.leave()
                print(error)
                return
            }
            group.leave()
        }
        group.notify(queue: .main) {
            completionHandler(self.questions)
        }
    }
    
    func getBeacons(completionHandler: @escaping (_ beacons: [Beacon]) -> Void){
        
        let group = DispatchGroup()
        group.enter()
        
        AF.request(beaconsUrl, method: .get).responseJSON{ response in
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
    
    
    func initUser(){

        AF.request(initUserUrl, method: .post).responseJSON{ response in

            switch response.result {
                case .success(let value) :
                   if let id = JSON(value)["_id"].string {
                   UserDefaults.standard.set(id, forKey: "userID")
                   }
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func postFeedback(feedback: Feedback){
    
            var json: [String : Any] = [:]
            json["roomId"] = feedback.roomID
            json["userId"] = feedback.userID

            var questions: [[String: String]] = []

            for elements in feedback.answers {
                var dict: [String: String] = [:]

                dict["_id"] = elements.questionID
                dict["answer"] = elements.answer
                
                questions.append(dict)
            }
            json["questions"] = questions
            
            AF.request(feedbackUrl, method: .post, parameters: json, encoding: JSONEncoding.default)
                .responseString { response in
                    switch response.result {
                    case.success(_):
                        print(response)
                    case.failure(let error):
                        print(error)
                    }
            }
    }
}
