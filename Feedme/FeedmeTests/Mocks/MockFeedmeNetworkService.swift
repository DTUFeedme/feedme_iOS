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
            completion(self.decoder.decodeFetchBuildings(data: mockFetchBuildingsResponse), nil)
        }
    }
    
    func postRoom(buildingId: String, name: String, completion: @escaping (String?, ServiceError?) -> Void) {
        if shouldReturnError {
            // Giving error response (the data put in the decoder is from the wrong resposne)
            if let roomid = self.decoder.decodePostRoom(data: mockFetchFeedbackResponse) {
                completion(roomid, nil)
            } else {
                completion(nil, ServiceError.error(description: ""))
            }
        } else {
            completion(self.decoder.decodePostRoom(data: mockPostRoomResponse), nil)
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
            if let _ = self.decoder.decodeToken(data: mockFetchFeedbackResponse) {
                completion(nil, nil)
            } else {
                completion(nil, ServiceError.error(description: ""))
            }
        } else {
            completion(self.decoder.decodePostSignalMap(data: mockPostSignalMapResponse as Any), nil)
        }
    }
    
    
    
    func fetchFeedback(questionID: String, roomID: String, time: Time, me: Bool, completion: @escaping ([AnsweredFeedback]?, ServiceError?) -> Void) {
        if shouldReturnError {
            completion(nil, ServiceError.error(description: ""))
        } else {
            completion(self.decoder.decodeFetchFeedback(data: mockFetchFeedbackResponse), nil)
        }
    }
    
    func login(email: String, password: String, completion: @escaping (ServiceError?) -> Void) {
        if shouldReturnError {
            // Giving wrong response
            if let _ = self.decoder.decodeToken(data: mockFetchFeedbackResponse) {
                completion(nil)
            } else {
                completion(ServiceError.error(description: ""))
            }
        } else {
            if let _ = self.decoder.decodeToken(data: mockLoginResponse) {
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
            if let _ = self.decoder.decodeToken(data: mockLoginResponse) {
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
            completion(self.decoder.decodeFetchQuestions(data: mockFetchQuestionsResponse),nil)
        }
    }
    
    func fetchAnsweredQuestions(roomID: String, time: Time, me: Bool, completion: @escaping ([AnsweredQuestion]?, ServiceError?) -> Void) {
        if shouldReturnError {
            completion(nil, ServiceError.error(description: ""))
        } else {
            completion(self.decoder.decodeFetchAnsweredQuestion(data: mockFetchAnsweredQuestionsResponse), nil)
        }
    }
}
