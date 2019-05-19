//
//  FeedmeNetworkServiceDecoder.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 13/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation
import SwiftyJSON

class FeedmeNetworkServiceDecoder {
    
    func decodeFetchAnsweredQuestion(data: Any) -> [AnsweredQuestion] {
        
        var answeredQuestions: [AnsweredQuestion] = []
        let json = JSON(data)
        for element in json {
            if let questionName = element.1["question"]["value"].string,
                let questionId = element.1["question"]["_id"].string,
                let questionCount = element.1["timesAnswered"].int {
                let answeredQuestion = AnsweredQuestion(question: questionName, questionId: questionId, answeredCount: questionCount)
                answeredQuestions.append(answeredQuestion)
            }
        }
        return answeredQuestions
    }
    
    func decodeFetchQuestions(data: Any) -> [Question] {
        
        var questions: [Question] = []
        let json = JSON(data)
        for element in json {
            if let questionName = element.1["value"].string, let id = element.1["_id"].string, let answersJson = element.1["answerOptions"].array {
                
                var answerOptions: [Question.answerOption] = []
                for element in answersJson {
                    if let answerValue = element["value"].string, let answerID = element["_id"].string {
                        let answerOption = Question.answerOption(id: answerID, value: answerValue)
                        answerOptions.append(answerOption)
                    }
                }
                let question = Question(id: id, question: questionName, answerOptions: answerOptions)
                questions.append(question)
            }
        }
        return questions
    }
    
    func decodeFetchBeacons(data: Any) -> [Beacon] {
        
        var beacons: [Beacon] = []
        let json = JSON(data)
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
        return beacons
    }
    
    func decodeFetchBuildings(data: Any) -> [Building] {
        var buildings: [Building] = []
        let json = JSON(data)
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
        return buildings
    }
    
    func decodeToken(data: Any) -> String? {
        let json = JSON(data)
        if let token = json["x-auth-token"].string {
            return token
        }
        return nil
    }
    
    func decodeFetchFeedback(data: Any) -> [AnsweredFeedback] {
        var feedback: [AnsweredFeedback] = []
        let json = JSON(data)
        for element in json {
            if let answer = element.1["answer"]["value"].string,
                let answerCount = element.1["timesAnswered"].int {
                let answer = AnsweredFeedback(answerOption: answer, answerCount: answerCount)
                feedback.append(answer)
            }
        }
        return feedback
    }
    
    func decodePostRoom(data: Any) -> String? {
        let json = JSON(data)
        if let roomId = json["_id"].string {
            return roomId
        }
        return nil
    }
    
    func decodePostSignalMap(data: Any) -> Room? {
        let json = JSON(data)
        if let room = json["room"].dictionaryObject {
            if let id = room["_id"] as? String, let name = room["name"] as? String {
                 return Room(id: id, name: name)
            }
        }
        return nil
    }
}