//
//  SampleTest.swift
//  UnitTests
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import XCTest

class SampleTest: XCTestCase {
    lazy var injector = TestInjector()

    override func setUp() {
        super.setUp()
        injector.load()
    }

    override func tearDown() {
        super.tearDown()
        injector.reset()
    }

    func testSample() {
    }
}
