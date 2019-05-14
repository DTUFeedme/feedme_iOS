//
//  FeedmeNetworkServiceTest.swift
//  FeedmeTests
//
//  Created by Christian Hjelmslund on 11/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import XCTest
@testable import Climify

class FeedmeNetworkServiceDecoderTest: XCTestCase {
 
    let feedmeNS = MockFeedmeNetworkService()
    
    func testPostRoom() {
        feedmeNS.shouldReturnError = true
        
        let testRoomId = "5cd7e911cd7521362637208f"
        
        feedmeNS.postRoom(buildingId: "id", name: "name") { roomId, error in
            XCTAssertNotNil(error)
            XCTAssertNil(roomId)
        }
        
        feedmeNS.shouldReturnError = false
        feedmeNS.postRoom(buildingId: "id", name: "name") { roomId, error in
            XCTAssertNil(error)
            XCTAssertNotNil(roomId)
            XCTAssertEqual(testRoomId, roomId)
        }
    }
    
    func testLogin() {
        
        let testEmail = "a@a.dk"
        let testPassword = "12345"
        
        feedmeNS.shouldReturnError = true
        feedmeNS.login(email: testEmail, password: testPassword) { error in
            XCTAssertNotNil(error)
        }
        feedmeNS.shouldReturnError = false
        feedmeNS.login(email: testEmail, password: testPassword) { error in
            XCTAssertNil(error)
        }
    }
    
    
    func testFetchAnsweredQuestions() {
        feedmeNS.shouldReturnError = true
        feedmeNS.fetchAnsweredQuestions(roomID: "id", time: Time.day, me: true) { questions, error in
            XCTAssertNil(questions)
            XCTAssertNotNil(error)
        }
        feedmeNS.shouldReturnError = false
        let question = (question: "How did you perceive the indoor air humidity?", questionId: "", answeredCount: 1)
        
        feedmeNS.fetchAnsweredQuestions(roomID: "id", time: Time.day, me: true) { questions, error in
            XCTAssertNil(error)
            XCTAssertEqual(question.question, questions?.first?.question)
            XCTAssertEqual(question.answeredCount, questions?.first?.answeredCount)
        }
    }
    
    func testFetchBeacons() {
        
        feedmeNS.shouldReturnError = true
        feedmeNS.fetchBeacons() { beacons, error in
            XCTAssertNil(beacons)
            XCTAssertNotNil(error)
        }
        
        feedmeNS.shouldReturnError = false
        let building = Building(id: "", name: "Building 303", rooms: nil)
        let beacon = Beacon(id: "", uuid: "f7826da6-4fa2-4e98-8024-bc5b71e0893b", name: "vIgJ", building: building)
        feedmeNS.fetchBeacons() { beacons, error in
            XCTAssertNil(error)
            XCTAssertNotNil(beacons)
            XCTAssertEqual(beacons?.first?.uuid, beacon.uuid)
            XCTAssertEqual(beacons?.first?.building.name, beacon.building.name)
            XCTAssertNil(beacons?.first?.building.rooms)
            XCTAssertEqual(beacons?.first?.name, beacon.name)
        }
    }
    
    func testFetchBuildings(){
        feedmeNS.shouldReturnError = true
        feedmeNS.fetchBuildings() { buildings, error in
            XCTAssertNil(buildings)
            XCTAssertNotNil(error)
        }
        let building = Building(id: "", name: "Building 303", rooms: [Room(id: "", name: "Rum1")])
        feedmeNS.shouldReturnError = false
        feedmeNS.fetchBuildings() { buildings, error in
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
        
        feedmeNS.shouldReturnError = true
        
        feedmeNS.postSignalMap(signalMap: signalMap, roomid: nil, buildingId: buildingId) { room, error in
            XCTAssertNil(room)
            XCTAssertNotNil(error)
        }
        
        feedmeNS.shouldReturnError = false
        
        feedmeNS.postSignalMap(signalMap: signalMap, roomid: nil, buildingId: buildingId) { room, error in
            XCTAssertNil(error)
            XCTAssertNotNil(room)
            XCTAssertEqual(room?.id, roomId)
        }
    }
   
    func testFetchQuestions(){
        feedmeNS.shouldReturnError = true
        feedmeNS.fetchQuestions(currentRoomID: "5cd710d0cd752136263717eb") { questions, error in
            XCTAssertNil(questions)
            XCTAssertNotNil(error)
        }
        feedmeNS.shouldReturnError = false
        let question = Question(id: "5cd710f9cd752136263717f6", question: "How did you perceive the indoor air humidity?", answerOptions: [Question.answerOption(id: "", value: "Very humid"), Question.answerOption(id: "", value: "Humid")])
        
        feedmeNS.fetchQuestions(currentRoomID: "5cd710d0cd752136263717eb") { questions, error in
            XCTAssertNotNil(questions)
            XCTAssertEqual(questions?.first?.question, question.question)
            XCTAssertEqual(questions?.first?.answerOptions.first?.value , question.answerOptions.first?.value)
            XCTAssertEqual(questions?.first?.id, question.id)
            XCTAssertEqual(questions?.first?.answerOptions[1].value, question.answerOptions[1].value)
        }
    }
    
    func testPostFeedback(){
        feedmeNS.shouldReturnError = true
        let feedback = Feedback(answerId: "id", roomID: "id", questionId: "id")
        feedmeNS.postFeedback(feedback: feedback) { error in
            XCTAssertNotNil(error)
        }
        feedmeNS.shouldReturnError = false
        feedmeNS.postFeedback(feedback: feedback) { error in
            XCTAssertNil(error)
        }
    }
    
    func testFetchToken(){
        feedmeNS.shouldReturnError = true
        
        feedmeNS.fetchToken(){ error in
            XCTAssertNotNil(error)
            
        }
        feedmeNS.shouldReturnError = false
        feedmeNS.fetchToken(){ error in
            XCTAssertNil(error)
        }
    }
    
    func testFetchFeedback(){
        feedmeNS.shouldReturnError = true
        
        feedmeNS.fetchFeedback(questionID: "id", roomID: "id", time: Time.day, me: true) { feedback, error in
            XCTAssertNotNil(error)
            XCTAssertNil(feedback)
        }
        
        feedmeNS.shouldReturnError = false
        let localFeedback = [(answerOption: "Humid", answerCount: 1)]
        feedmeNS.fetchFeedback(questionID: "id", roomID: "id", time: Time.day, me: true) { feedback, error in
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
