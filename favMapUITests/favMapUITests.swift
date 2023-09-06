//
//  favMapUITests.swift
//  favMapUITests
//
//  Created by Şevval Mertoğlu on 23.08.2023.
//

import XCTest

final class favMapUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testInformationButton() throws {
        
        let app = XCUIApplication()
        app.launch()
        
        let profilpage = app.tabBars["Tab Bar"].buttons["Profile"]
        let informationbutton = app/*@START_MENU_TOKEN@*/.staticTexts[" Personal Information"]/*[[".buttons[\" Personal Information\"].staticTexts[\" Personal Information\"]",".staticTexts[\" Personal Information\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let element = app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        let backbutton = app.navigationBars["favMap.InformationView"].buttons["Back"]
                 
        
        profilpage.tap()
        informationbutton.tap()
        element.tap()
        
        XCTAssert(backbutton.exists)
        
    }

    func testExitButton() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
       
        let profilpage = app.tabBars["Tab Bar"].buttons["Profile"]
        
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
        let element0 = element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        let exitbutton = app.buttons["Exit"]
        
        let logınbutton = app.buttons["Login"]
        
        profilpage.tap()
        element0.tap()
        exitbutton.tap()
        
                XCTAssert(logınbutton.exists)
      
            }

        }
    

