//
//  AsyncImageViewModelTests.swift
//  UnitTests
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/29/20.
//

import Combine
import Core
@testable import PostUI
import SwiftUI
import XCTest

class AsyncImageViewModelTests: XCTestCase {
    lazy var injector = TestInjector()
    var viewModel = AsyncImageViewModel()
    var disposeBag = Set<AnyCancellable>()
    var imageCacheProvider: ImageCacheProviderMock? {
        viewModel.imageCacheProvider as? ImageCacheProviderMock
    }
    var requestProvider: RequestProviderMock? {
        viewModel.requestProvider as? RequestProviderMock
    }

    override func setUp() {
        super.setUp()
        injector.load()
        imageCacheProvider?.retrieveHandler = nil
        requestProvider?.requestHandler = nil
        imageCacheProvider?.saveHandler = nil
        disposeBag.removeAll()
    }

    override func tearDown() {
        super.tearDown()
        injector.reset()
    }

    func testNoImageWhenUrlIsNil() {
        // Given
        let loadImageExpectation = expectation(description: "loadImageExpectation")
        // When
        viewModel
            .loadImage(nil)
            .sink { image in
                // Then
                XCTAssertEqual(image, nil)
                loadImageExpectation.fulfill()
            }
            .store(in: &disposeBag)
        wait(for: [loadImageExpectation], timeout: 1.0)
    }

    func testCacheIsReturned() {
        // Given
        let fakeImage = UIImage(
            color: .red,
            size: .init(width: 20, height: 20)
        )
        let fakeURL = URL(string: "https://localhost:8080")
        imageCacheProvider?.retrieveHandler = { url in
            XCTAssertEqual(url, fakeURL)
            return fakeImage
        }
        let loadImageExpectation = expectation(description: "loadImageExpectation")
        // When
        viewModel
            .loadImage(fakeURL)
            .sink { image in
                // Then
                XCTAssertEqual(image, fakeImage)
                loadImageExpectation.fulfill()
            }
            .store(in: &disposeBag)
        wait(for: [loadImageExpectation], timeout: 1.0)
    }

    func testRequestedImageIsReturnedAndCacheIsSaved() {
        // Given
        let fakeImage = UIImage(
            color: .red,
            size: .init(width: 20, height: 20)
        )
        let fakeImageData = fakeImage?.pngData() ?? Data()
        let fakeURL = URL(string: "https://localhost:8080")
        requestProvider?.requestUrlHandler = { url in
            XCTAssertEqual(url, fakeURL)
            return Just<Data>(fakeImageData)
                .setFailureType(to: DataError.self)
                .eraseToAnyPublisher()
        }
        let saveCacheExpectation = expectation(description: "saveCacheExpectation")
        imageCacheProvider?.saveHandler = { image, url in
            XCTAssertEqual(image.pngData(), fakeImage?.pngData())
            XCTAssertEqual(url, fakeURL)
            saveCacheExpectation.fulfill()
        }
        let loadImageExpectation = expectation(description: "loadImageExpectation")
        // When
        viewModel
            .loadImage(fakeURL)
            .sink { image in
                // Then
                XCTAssertEqual(image?.pngData(), fakeImage?.pngData())
                loadImageExpectation.fulfill()
            }
            .store(in: &disposeBag)
        wait(for: [loadImageExpectation, saveCacheExpectation], timeout: 1.0)
    }
}
