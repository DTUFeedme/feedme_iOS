//
//  MockFeedmeNetworkService.swift
//  FeedmeTests
//
//  Created by Christian Hjelmslund on 11/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation
@testable import Feedme

class MockFeedmeNetworkService {
    
    var shouldReturnError = false
    private let decoder = FeedmeNetworkServiceDecoder()

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
    
    let mockFetchFeedbackResponse = [
    [
        "answer": [
            "_id": "5cd710f9cd752136263717f9",
            "value": "Humid"
        ],
        "timesAnswered": 1
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
}

extension MockFeedmeNetworkService: FeedmeNetworkServiceProtocol {
    
    func fetchBuildings(completion: @escaping ([Building]?, ServiceError?) -> Void) {
        if shouldReturnError {
            completion(nil, ServiceError.error(description: ""))
        } else {
            let data = try? JSONSerialization.data(withJSONObject: mockFetchBuildingsResponse, options: .prettyPrinted)
            completion(self.decoder.decodeFetchBuildings(data: data!), nil)
        }
    }
    
    func postRoom(buildingId: String, name: String, completion: @escaping (String?, ServiceError?) -> Void) {
        if shouldReturnError {
            // Giving error response (the data put in the decoder is from the wrong resposne)
            let data = try? JSONSerialization.data(withJSONObject: mockFetchFeedbackResponse, options: .prettyPrinted)
            if let roomid = self.decoder.decodePostRoom(data: data) {
                completion(roomid, nil)
            } else {
                completion(nil, ServiceError.error(description: ""))
            }
        } else {
            let data = try? JSONSerialization.data(withJSONObject: mockPostRoomResponse, options: .prettyPrinted)
            completion(self.decoder.decodePostRoom(data: data!), nil)
        }
    }
    
    
    
    func postFeedback(feedback: Feedback, completion: @escaping (ServiceError?) -> Void) {
        if shouldReturnError {
            // Giving error response
            completion(ServiceError.error(description: ""))
        } else {
            completion(nil)
        }
    }
    
   
    
    
    func postSignalMap(signalMap: [[String: Any]], roomid: String?, buildingId: String?, completion: @escaping (Room?, ServiceError?) -> Void) {
        if shouldReturnError {
            // Giving error response (the data put in the decoder is from the wrong resposne)
            let data = try? JSONSerialization.data(withJSONObject: mockFetchFeedbackResponse, options: .prettyPrinted)
            if let _ = self.decoder.decodeToken(data: data!) {
                completion(nil, nil)
            } else {
                completion(nil, ServiceError.error(description: ""))
            }
        } else {
            let data = try? JSONSerialization.data(withJSONObject: mockPostSignalMapResponse, options: .prettyPrinted)
            completion(self.decoder.decodePostSignalMap(data: data!), nil)
        }
    }
    
    
    
    func fetchFeedback(questionID: String, roomID: String, time: Time, me: Bool, completion: @escaping ([AnsweredFeedback]?, ServiceError?) -> Void) {
        if shouldReturnError {
            completion(nil, ServiceError.error(description: ""))
        } else {
            let data = try? JSONSerialization.data(withJSONObject: mockFetchFeedbackResponse, options: .prettyPrinted)
            completion(self.decoder.decodeFetchFeedback(data: data!), nil)
        }
    }
    
    func login(email: String, password: String, completion: @escaping (ServiceError?) -> Void) {
        if shouldReturnError {
            // Giving wrong response
            let data = try? JSONSerialization.data(withJSONObject: mockFetchFeedbackResponse, options: .prettyPrinted)
            if let _ = self.decoder.decodeToken(data: data!) {
                completion(nil)
            } else {
                completion(ServiceError.error(description: ""))
            }
        } else {
            let data = try? JSONSerialization.data(withJSONObject: mockLoginResponse, options: .prettyPrinted)
            if let _ = self.decoder.decodeToken(data: data!) {
                completion(nil)
            } else {
                completion(ServiceError.error(description: ""))
            }
        }
    }
    
    func fetchToken(completion: @escaping (ServiceError?) -> Void) {
        if shouldReturnError {
            completion(ServiceError.error(description: ""))
        } else {
            let data = try? JSONSerialization.data(withJSONObject: mockLoginResponse, options: .prettyPrinted)
            if let _ = self.decoder.decodeToken(data: data!) {
                completion(nil)
            } else {
                completion(ServiceError.error(description: ""))
            }
        }
    }
    
    func fetchBeacons(completion: @escaping ([Beacon]?, ServiceError?) -> Void) {
        if shouldReturnError {
            completion(nil, ServiceError.error(description: ""))
        } else {
            let data = try? JSONSerialization.data(withJSONObject: mockFetchBeaconsResponse, options: .prettyPrinted)
            completion(self.decoder.decodeFetchBeacons(data: data!),nil)
        }
    }
    
    func fetchQuestions(currentRoomID: String, completion: @escaping ([Question]?, ServiceError?) -> Void) {
        if shouldReturnError {
            completion(nil, ServiceError.error(description: ""))
        } else {
            let data = try? JSONSerialization.data(withJSONObject: mockFetchQuestionsResponse, options: .prettyPrinted)
            completion(self.decoder.decodeFetchQuestions(data: data!),nil)
        }
    }
    
    func fetchAnsweredQuestions(roomID: String, time: Time, me: Bool, completion: @escaping ([AnsweredQuestion]?, ServiceError?) -> Void) {
        if shouldReturnError {
            completion(nil, ServiceError.error(description: ""))
        } else {
            let data = try? JSONSerialization.data(withJSONObject: mockFetchAnsweredQuestionsResponse, options: .prettyPrinted)
            completion(self.decoder.decodeFetchAnsweredQuestion(data: data!), nil)
        }
    }
}
