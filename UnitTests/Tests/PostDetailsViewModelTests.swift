//
//  PostDetailsViewModelTests.swift
//  UnitTests
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Combine
import Core
@testable import PostUI
import SwiftUI
import XCTest

class PostDetailsViewModelTests: XCTestCase {
    lazy var injector = TestInjector()
    @ObservedObject var viewModel = PostDetailsViewModel()
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
        viewModel.post = Post()
        viewModel.post?.author = "AUTHOR"
        viewModel.post?.thumbnailURL = "IMAGEURL"
        viewModel.post?.title = "TITLE"
        let authorExpectation = expectation(description: "authorExpectation")
        let imageURLExpectation = expectation(description: "imageURLExpectation")
        let titleExpectation = expectation(description: "titleExpectation")
        // When
        viewModel.load()
        // Then
        viewModel
            .$author
            .sink { author in
                XCTAssertEqual(author, "AUTHOR")
                authorExpectation.fulfill()
            }
            .store(in: &disposeBag)
        viewModel
            .$imageURL
            .sink { imageURL in
                XCTAssertEqual(imageURL, "IMAGEURL")
                imageURLExpectation.fulfill()
            }
            .store(in: &disposeBag)
        viewModel
            .$title
            .sink { title in
                XCTAssertEqual(title, "TITLE")
                titleExpectation.fulfill()
            }
            .store(in: &disposeBag)
        wait(for: [authorExpectation, imageURLExpectation, titleExpectation],
             timeout: 1.0)
    }
}
