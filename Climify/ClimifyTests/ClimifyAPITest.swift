//
//  ClimifyAPITest.swift
//  ClimifyTests
//
//  Created by Christian Hjelmslund on 11/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import XCTest
import Alamofire
@testable import Climify

class ClimifyAPITest: XCTestCase {
 
    let api = MockClimifyAPI()
    override func setUp() {
       
    }

    override func tearDown() {
    }

    func testLogin() {
        
        let testEmail = "a@a.dk"
        let testPassword = "12345"
        
        api.shouldReturnError = true
        api.login(email: testEmail, password: testPassword) { error in
            XCTAssertNotNil(error)
        }
        api.shouldReturnError = false
        api.login(email: testEmail, password: testPassword) { error in
            XCTAssertNil(error)
        }
    }
    
    func testPostRoom() {
        api.shouldReturnError = true
        
        let testRoomId = "5cd7e911cd7521362637208f"
        
        api.postRoom(buildingId: "id", name: "name") { roomId, error in
            XCTAssertNotNil(error)
            XCTAssertNil(roomId)
        }
        
        
        api.shouldReturnError = false
        api.postRoom(buildingId: "id", name: "name") { roomId, error in
            XCTAssertNil(error)
            XCTAssertNotNil(roomId)
            XCTAssertEqual(testRoomId, roomId)
        }
    }
    
    func testFetchAnsweredQuestions() {
        api.shouldReturnError = true
        api.fetchAnsweredQuestions(roomID: "id", time: Time.day, me: true) { questions, error in
            XCTAssertNil(questions)
            XCTAssertNotNil(error)
        }
        api.shouldReturnError = false
        let question = (question: "How did you perceive the indoor air humidity?", questionId: "", answeredCount: 1)
        
        api.fetchAnsweredQuestions(roomID: "id", time: Time.day, me: true) { questions, error in
            XCTAssertNil(error)
            XCTAssertEqual(question.question, questions?.first?.question)
            XCTAssertEqual(question.answeredCount, questions?.first?.answeredCount)
        }
    }
    
    func testFetchBeacons() {
        
        api.shouldReturnError = true
        api.fetchBeacons() { beacons, error in
            XCTAssertNil(beacons)
            XCTAssertNotNil(error)
        }
        
        api.shouldReturnError = false
        let building = Building(id: "", name: "Building 303", rooms: nil)
        let beacon = Beacon(id: "", uuid: "f7826da6-4fa2-4e98-8024-bc5b71e0893b", name: "vIgJ", building: building)
        api.fetchBeacons() { beacons, error in
            XCTAssertNil(error)
            XCTAssertNotNil(beacons)
            XCTAssertEqual(beacons?.first?.uuid, beacon.uuid)
            XCTAssertEqual(beacons?.first?.building.name, beacon.building.name)
            XCTAssertNil(beacons?.first?.building.rooms)
            XCTAssertEqual(beacons?.first?.name, beacon.name)
        }
    }
    
    func testFetchBuildings(){
        api.shouldReturnError = true
        api.fetchBuildings() { buildings, error in
            XCTAssertNil(buildings)
            XCTAssertNotNil(error)
        }
        let building = Building(id: "", name: "Building 303", rooms: [Room(id: "", name: "Rum1")])
        api.shouldReturnError = false
        api.fetchBuildings() { buildings, error in
            XCTAssertNotNil(buildings)
            XCTAssertNil(error)
            XCTAssertEqual(buildings?.first?.name, building.name)
            XCTAssertEqual(buildings?.first?.rooms?.first?.name, building.rooms?.first?.name)

        }
    }
    
    func testPostSignalMap(){
        let signalMap = [["beaconId": "5cd71058cd752136263717ea", "signals": [-56.8]]]
        let roomId = "5cd710d0cd752136263717eb"
        let buildingId = "5cd491da2fc512294ee17df9"
        
        api.shouldReturnError = true
        
        api.postSignalMap(signalMap: signalMap, roomid: nil, buildingId: buildingId) { room, error in
            XCTAssertNil(room)
            XCTAssertNotNil(error)
        }
        
        api.shouldReturnError = false
        
        api.postSignalMap(signalMap: signalMap, roomid: nil, buildingId: buildingId) { room, error in
            XCTAssertNil(error)
            XCTAssertNotNil(room)
            XCTAssertEqual(room?.id, roomId)
        }
    }
   
    func testFetchQuestions(){
        api.shouldReturnError = true
        api.fetchQuestions(currentRoomID: "5cd710d0cd752136263717eb") { questions, error in
            XCTAssertNil(questions)
            XCTAssertNotNil(error)
        }
        api.shouldReturnError = false 
        let question = Question(questionID: "5cd710f9cd752136263717f6", question: "How did you perceive the indoor air humidity?", answerOptions: [Question.answerOption(id: "", value: "Very humid"), Question.answerOption(id: "", value: "Humid")])
        
        api.fetchQuestions(currentRoomID: "5cd710d0cd752136263717eb") { questions, error in
            XCTAssertNotNil(questions)
            XCTAssertEqual(questions?.first?.question, question.question)
            XCTAssertEqual(questions?.first?.answerOptions.first?.value , question.answerOptions.first?.value)
            XCTAssertEqual(questions?.first?.id, question.id)
            XCTAssertEqual(questions?.first?.answerOptions[1].value, question.answerOptions[1].value)
        }
    }
    
    func testPostFeedback(){
        api.shouldReturnError = true
        let feedback = Feedback(answerId: "id", roomID: "id", questionId: "id")
        api.postFeedback(feedback: feedback) { error in
            XCTAssertNotNil(error)
        }
        api.shouldReturnError = false
        api.postFeedback(feedback: feedback) { error in
            XCTAssertNil(error)
        }
    }
    
    func testFetchToken(){
        api.shouldReturnError = true
        
        api.fetchToken(){ error in
            XCTAssertNotNil(error)
            
        }
        api.shouldReturnError = false
        api.fetchToken(){ error in
            XCTAssertNil(error)
        }
    }
    
    func testFetchFeedback(){
        api.shouldReturnError = true
        
        api.fetchFeedback(questionID: "id", roomID: "id", time: Time.day, me: true) { feedback, error in
            XCTAssertNotNil(error)
            XCTAssertNil(feedback)
        }
        
        api.shouldReturnError = false
        let localFeedback = [(answerOption: "Humid", answerCount: 1)]
        api.fetchFeedback(questionID: "id", roomID: "id", time: Time.day, me: true) { feedback, error in
            XCTAssertNil(error)
            XCTAssertNotNil(feedback)
            XCTAssertEqual(localFeedback.first?.answerOption, feedback?.first?.answerOption)
            XCTAssertEqual(localFeedback.first?.answerCount, feedback?.first?.answerCount)
            XCTAssertEqual(localFeedback.count, feedback?.count)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
