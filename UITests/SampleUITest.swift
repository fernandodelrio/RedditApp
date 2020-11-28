//
//  SampleUITest.swift
//  UITests
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import XCTest

class SampleUITest: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testPeopleToEpisodeFlow() {
        let app = XCUIApplication()
        app.launch()
    }
}
