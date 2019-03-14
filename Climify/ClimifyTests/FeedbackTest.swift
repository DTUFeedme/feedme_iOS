//
//  FeedbackTest.swift
//  ClimifyTests
//
//  Created by Christian Hjelmslund on 11/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import XCTest
@testable import Climify
class FeedbackTest: XCTestCase {
    
    let feedback = Feedback(answers: [Answer(questionID: "qID", answer: 5)], roomID: "roomID")
    
    func testUserName(){
        
        if let string = feedback.userID {
            let regexUserID = try! NSRegularExpression(pattern: "[a-z0-9]{24}")
            let range = NSRange(location: 0, length: string.count)
            XCTAssertNotNil(regexUserID.firstMatch(in: string, options: [], range: range))
            
        }
    }
}
