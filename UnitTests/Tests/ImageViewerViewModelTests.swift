//
//  ImageViewerViewModelTests.swift
//  UnitTests
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/29/20.
//

import Combine
import Core
@testable import PostUI
import SwiftUI
import XCTest

class ImageViewerViewModelTests: XCTestCase {
    lazy var injector = TestInjector()
    var viewModel = ImageViewerViewModel()
    var disposeBag = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        injector.load()
        disposeBag.removeAll()
    }

    override func tearDown() {
        super.tearDown()
        injector.reset()
    }

    func testLoadMakesViewModelNotifyView() {
        // Given
        let imageURLExpectation = expectation(description: "imageURLExpectation")
        viewModel.imageURL = "IMAGEURL"
        viewModel
            .urlPublisher
            .sink { imageURL in
                // Then
                XCTAssertEqual(imageURL, "IMAGEURL")
                imageURLExpectation.fulfill()
            }
            .store(in: &disposeBag)
        // When
        viewModel.load()
        wait(for: [imageURLExpectation], timeout: 1.0)
    }
}
