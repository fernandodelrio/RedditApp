//
//  PostFlowUITest.swift
//  UITests
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import XCTest

class PostFlowUITest: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testBasicFlow() {
        let app = XCUIApplication()
        app.launch()
    }
}
