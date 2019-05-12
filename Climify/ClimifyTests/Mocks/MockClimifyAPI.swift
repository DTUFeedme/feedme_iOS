//
//  MockClimifyAPI.swift
//  ClimifyTests
//
//  Created by Christian Hjelmslund on 11/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation
@testable import Climify

class MockClimifyAPI {
    
    var shouldReturnError = false

    convenience init() {
        self.init(false)
    }
    
    init(_ shouldReturnError: Bool) {
        self.shouldReturnError = shouldReturnError
    }
    
    let mockFetchQuestionsResponse = [
        [
            "rooms": [
                "5cd710d0cd752136263717eb"
            ],
            "isActive": true,
            "_id": "5cd710f9cd752136263717f6",
            "value": "How did you perceive the indoor air humidity?",
            "answerOptions": [
                [
                    "_id": "5cd710f9cd752136263717f7",
                    "value": "Very humid",
                    "__v": 0
                ],
                [
                    "_id": "5cd710f9cd752136263717f9",
                    "value": "Humid",
                    "__v": 0
                ],
                [
                    "_id": "5cd710f9cd752136263717fb",
                    "value": "Fine",
                    "__v": 0
                ],
                [
                    "_id": "5cd710f9cd752136263717fd",
                    "value": "Dry",
                    "__v": 0
                ],
                [
                    "_id": "5cd710f9cd752136263717ff",
                    "value": "Very dry",
                    "__v": 0
                ]
            ],
            "__v": 0
        ]
    ]
    
    let mockFetchBeaconsResponse = [
        [
            "_id": "5cd71058cd752136263717ea",
            "building": [
                "feedback": [],
                "_id": "5cd491da2fc512294ee17df9",
                "name": "Building 303",
                "__v": 0
            ],
            "name": "vIgJ",
            "uuid": "f7826da6-4fa2-4e98-8024-bc5b71e0893b",
            "__v": 0
        ]
    ]
    
    let mockFetchAnsweredQuestionsResponse = [
    [
        "question": [
            "value": "How did you perceive the indoor air humidity?",
            "_id": "5cd710f9cd752136263717f6"
        ],
        "timesAnswered": 1
        ]
    ]
    
    let fetchFeedbackResponse = [
    [
        "answer": [
            "_id": "5cd710f9cd752136263717f9",
            "value": "Humid"
        ],
        "timesAnswered": 1
        ]
    ]
    
    let mockFetchBuildingsResponse = [
        [
            "name": "Building 303",
            "_id": "5cd491da2fc512294ee17df9",
            "rooms": [
                [
                    "_id": "5cd710d0cd752136263717eb",
                    "name": "Rum1",
                    "building": "5cd491da2fc512294ee17df9",
                    "__v": 0
                ],
                [
                    "_id": "5cd7e911cd7521362637208f",
                    "name": "Test Room",
                    "building": "5cd491da2fc512294ee17df9",
                    "__v": 0
                ]
            ]
        ],
        [
            "name": "Building 308",
            "_id": "5cd7fa95cd75213626372096",
            "rooms": []
        ]
    ]
    
    let mockLoginResponse = ["x-auth-token": "1234567810"]
    
    let mockPostRoomResponse: [String : Any] = [
        "_id": "5cd7e911cd7521362637208f",
        "name": "Test Room",
        "building": "5cd491da2fc512294ee17df9",
        "__v": 0
        ]
    
    let mockPostSignalMapResponse: [String : Any] = [
        "_id" : "5cd7f39ccd75213626372092",
        "isActive" : false,
        "beacons" : [
            [
                "_id" : "5cd71058cd752136263717ea",
                "signals" : [
                    -57.200000000000003
                ]
            ]
        ],
        "__v" : 0,
        "room" : [
            "_id" : "5cd710d0cd752136263717eb",
            "__v" : 0,
            "building" : "5cd491da2fc512294ee17df9",
            "name" : "Rum1"
        ]
    ]
    
    
}
extension MockClimifyAPI: ClimifyAPIProtocol {
    
    func postSignalMap(signalMap: [Any], roomid: String?, buildingId: String?, completion: @escaping (Room?, ServiceError?) -> Void) {
        if shouldReturnError {
            completion(nil, ServiceError.error(description: ""))
        } else {
            if let room = mockPostSignalMapResponse["room"] as! [String: Any]? {
                if let id = room["_id"] as? String, let name = room["name"] as? String {
                    let room = Room(id: id, name: name)
                    completion(room, nil)
                } else {
                    completion(nil, ServiceError.error(description: ""))
                }
            } else {
                completion(nil, ServiceError.error(description: ""))
            }
        }
    }
    
    func postRoom(buildingId: String, name: String, completion: @escaping (String?, ServiceError?) -> Void) {
        
        if shouldReturnError {
            completion(nil, ServiceError.error(description: ""))
        } else {
            if let roomId = mockPostRoomResponse["_id"] as! String? {
                completion(roomId, nil)
            } else {
                completion(nil, ServiceError.error(description: ""))
            }
        }
    }
    
    
    func fetchFeedback(questionID: String, roomID: String, time: Time, me: Bool, completion: @escaping ([(answerOption: String, answerCount: Int)]?, ServiceError?) -> Void) {
        if shouldReturnError {
            completion(nil, ServiceError.error(description: ""))
        } else {
            
            var feedback: [(answerOption: String, answerCount: Int)] = []
            
            for element in fetchFeedbackResponse {
                if let answerElement = element["answer"] as! [String:Any]? {
                    print(answerElement)
                    if let value = answerElement["value"] as! String?,
                        let answerCount = element["timesAnswered"] as! Int? {
                        let answer = (answerOption: value, answerCount: answerCount)
                        feedback.append(answer)
                    }
                }
            }
            if feedback.isEmpty {
                completion(nil, ServiceError.error(description: ""))
            } else {
                completion(feedback, nil)
            }
        }
    }
    
    
    func fetchToken(completion: @escaping (ServiceError?) -> Void) {
        if shouldReturnError {
            completion(ServiceError.error(description: ""))
        } else {
            completion(nil)
        }
    }
    
    
    func fetchBuildings(completion: @escaping ([Building]?, ServiceError?) -> Void) {
        if shouldReturnError {
            completion(nil, ServiceError.error(description: ""))
        } else {
            var buildings = [Building]()
            for element in mockFetchBuildingsResponse {
                var buildingRooms: [Room] = []
                if let buildingName = element["name"] as! String?,
                    let buildingId = element["_id"] as! String?,
                let rooms = element["rooms"] as! [[String: Any]]? {
                    for room in rooms {
                        if let roomId = room["_id"] as! String?,
                            let roomName = room["name"] as! String? {
                            let buildingRoom = Room(id: roomId, name: roomName)
                            buildingRooms.append(buildingRoom)
                        }
                    }
                    let building = Building(id: buildingId, name: buildingName, rooms: buildingRooms)
                    buildings.append(building)
                }
            }
            if buildings.isEmpty {
                completion(nil, ServiceError.error(description: ""))
            } else {
                 completion(buildings,nil )
            }
        }
    }
    
    
    func fetchAnsweredQuestions(roomID: String, time: Time, me: Bool, completion: @escaping ([(question: String, questionId: String, answeredCount: Int)]?, ServiceError?) -> Void) {
        if shouldReturnError {
            completion(nil, ServiceError.error(description: ""))
        } else {
            var questions = [(question: String, questionId: String, answeredCount: Int)]()
            for element in mockFetchAnsweredQuestionsResponse {
                if let question = element["question"] as! [String: Any]? {
                    if let questionName = question["value"] as! String?,
                    let questionId = question["_id"] as! String?,
                    let questionCount = element["timesAnswered"] as! Int?{
                        let question = (question: questionName,questionId: questionId,answeredCount: questionCount)
                        questions.append(question)
                    }
                }
            }
            if questions.isEmpty {
                completion(nil, ServiceError.error(description: ""))
            } else {
                completion(questions, nil)
            }
        }
    }
    
    
    func fetchBeacons(completion: @escaping ([Beacon]?, ServiceError?) -> Void) {
        if shouldReturnError {
            completion(nil, ServiceError.error(description: ""))
        } else {
            var beacons = [Beacon]()
            for element in mockFetchBeaconsResponse {
                if let name = element["name"] as! String?,
                let id = element["_id"] as! String?,
                let uuid = element["uuid"] as! String?,
                let building = element["building"] as! [String: Any]? {
                    if let buildingId = building["_id"] as! String?, let buildingName = building["name"] as! String?{
                        let building = Building(id: buildingId, name: buildingName, rooms: nil)
                        let beacon = Beacon(id: id, uuid: uuid, name: name, building: building)
                        beacons.append(beacon)
                    }
                }
            }
            if beacons.isEmpty {
                completion(nil, ServiceError.error(description: ""))
            } else {
                completion(beacons, nil)
            }
        }
    }
    
    func fetchQuestions(currentRoomID: String, completion: @escaping (_ questions: [Question]?, _ error: ServiceError?) -> Void) {
        if shouldReturnError {
            completion(nil, ServiceError.error(description: ""))
        } else {
            var questions = [Question]()
            for element in mockFetchQuestionsResponse {
                if let questionName = element["value"] as! String?, let id = element["_id"] as! String?, let answersJson = element["answerOptions"] as! [[String:Any]]? {
                    var answerOptions: [Question.answerOption] = []
                    for element in answersJson {
                        if let answerValue = element["value"] as! String?, let answerID = element["_id"] as! String? {
                            let answerOption = Question.answerOption(id: answerID, value: answerValue)
                            answerOptions.append(answerOption)
                        }
                    }
                    let question = Question(questionID: id, question: questionName, answerOptions: answerOptions)
                    questions.append(question)
                }
            }
            if questions.isEmpty {
                completion(nil, ServiceError.error(description: ""))
            } else {
                completion(questions, nil)
            }
        }
    }
    
    
    func postFeedback(feedback: Feedback, completion: @escaping (ServiceError?) -> Void) {
        
        if shouldReturnError {
            completion(ServiceError.error(description: ""))
        } else {
            completion(nil)
        }
    }
    
    func login(email: String, password: String, completion: @escaping (ServiceError?) -> Void) {
        
        if shouldReturnError {
            completion(ServiceError.error(description: ""))
        } else {
            if let _ = mockLoginResponse["x-auth-token"] as String? {
                completion(nil)
            } else {
                completion(ServiceError.error(description: ""))
            }
        }
    }
}
