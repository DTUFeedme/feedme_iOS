//
//  FeedmeUITests.swift
//  FeedmeUITests
//
//  Created by Sebastian on 08/04/2021.
//  Copyright © 2021 Christian Hjelmslund. All rights reserved.
//

import XCTest

class FeedmeUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
//    func test2(){
//        let app = XCUIApplication()
//        Snapshot.setupSnapshot(app)
//        app.launch()
//
//        app.tabBars.buttons.element(boundBy: 1).tap()
//    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        print("works")
        let app = XCUIApplication()
        Snapshot.setupSnapshot(app)
        app.launch()
        
        
        if app.staticTexts["termsOfService"].exists{
            app.swipeUp()
            app.buttons["doneBtn"].tap()
        }
        
        //sleep(2)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        app.navigationBars.buttons.element(boundBy: 1).tap()
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        sleep(1)
        
        snapshot("01Feedback")
        
        app.tables.cells.element(boundBy: 1).tap()
        
        sleep(2)
        
        snapshot("02Feedbackgiven")
        
        app.buttons.element(boundBy: 2).tap()
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        app.buttons["everyoneBtn"].tap()
        
        app.tables.cells.element(boundBy: 0).tap()
        
        snapshot("03Data")
        
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *){
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
