//
//  PostListViewModelTests.swift
//  UnitTests
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/29/20.
//

import Combine
import Core
@testable import PostUI
import SwiftUI
import XCTest

class PostListViewModelTests: XCTestCase {
    lazy var injector = TestInjector()
    lazy var viewModel = PostListViewModel()
    var disposeBag = Set<AnyCancellable>()
    var postProvider: PostProviderMock? {
        viewModel.postProvider as? PostProviderMock
    }

    override func setUp() {
        super.setUp()
        injector.load()
        postProvider?.loadMoreHandler = nil
        postProvider?.updatePostsHandler = nil
        postProvider?.refreshHandler = nil
        viewModel.unfilteredPosts = []
        viewModel.posts = []
        disposeBag.removeAll()
    }

    override func tearDown() {
        super.tearDown()
        injector.reset()
    }

    func testLoadCallsPostProviderLoadMore() {
        // Given
        let loadMoreExpectation = expectation(description: "loadMoreExpectation")
        postProvider?.loadMoreHandler = {
            loadMoreExpectation.fulfill()
        }
        // When
        viewModel.load()
        // Then
        wait(for: [loadMoreExpectation], timeout: 1.0)
    }

    func testDismissByIdentifier() {
        // Given
        var post1 = Post()
        var post2 = Post()
        post1.identifier = "IDENTIFIER1"
        post2.identifier = "IDENTIFIER2"
        viewModel.unfilteredPosts = [post1, post2]
        viewModel.posts = [post1, post2]
        let updatePostsExpectation = expectation(description: "updatePostsExpectation")
        postProvider?.updatePostsHandler = { posts in
            XCTAssertEqual(posts.count, 1)
            XCTAssertEqual(posts.first?.identifier, "IDENTIFIER1")
            XCTAssertEqual(posts.first?.isDismissed, true)
            updatePostsExpectation.fulfill()
            return Just(()).eraseToAnyPublisher()
        }
        // When
        viewModel.dismiss(identifier: "IDENTIFIER1")
        // Then
        XCTAssertEqual(viewModel.unfilteredPosts.count, 2)
        XCTAssertEqual(viewModel.posts.count, 1)
        XCTAssertEqual(viewModel.unfilteredPosts.first?.isDismissed, true)
        XCTAssertEqual(viewModel.unfilteredPosts.last?.isDismissed, false)
        XCTAssertEqual(viewModel.posts.first?.identifier, "IDENTIFIER2")
        wait(for: [updatePostsExpectation], timeout: 1.0)
    }

    func testDismissAll() {
        // Given
        var post1 = Post()
        var post2 = Post()
        post1.identifier = "IDENTIFIER1"
        post2.identifier = "IDENTIFIER2"
        viewModel.unfilteredPosts = [post1, post2]
        viewModel.posts = [post1, post2]
        let updatePostsExpectation = expectation(description: "updatePostsExpectation")
        postProvider?.updatePostsHandler = { posts in
            XCTAssertEqual(posts.count, 2)
            XCTAssertEqual(posts.first?.identifier, "IDENTIFIER1")
            XCTAssertEqual(posts.last?.identifier, "IDENTIFIER2")
            XCTAssertEqual(posts.first?.isDismissed, true)
            XCTAssertEqual(posts.last?.isDismissed, true)
            updatePostsExpectation.fulfill()
            return Just(()).eraseToAnyPublisher()
        }
        // When
        viewModel.dismissAll()
        // Then
        XCTAssertEqual(viewModel.unfilteredPosts.count, 2)
        XCTAssertEqual(viewModel.posts.count, 0)
        XCTAssertEqual(viewModel.unfilteredPosts.first?.isDismissed, true)
        XCTAssertEqual(viewModel.unfilteredPosts.last?.isDismissed, true)
        wait(for: [updatePostsExpectation], timeout: 1.0)
    }

    func testSaveUnreadWhenSelected() {
        // Given
        var post1 = Post()
        var post2 = Post()
        post1.identifier = "IDENTIFIER1"
        post2.identifier = "IDENTIFIER2"
        viewModel.unfilteredPosts = [post1, post2]
        viewModel.posts = [post1, post2]
        let updatePostsExpectation = expectation(description: "updatePostsExpectation")
        postProvider?.updatePostsHandler = { posts in
            XCTAssertEqual(posts.count, 1)
            XCTAssertEqual(posts.first?.identifier, "IDENTIFIER2")
            XCTAssertEqual(posts.first?.isUnread, false)
            updatePostsExpectation.fulfill()
            return Just(()).eraseToAnyPublisher()
        }
        // When
        viewModel.select(index: 1)
        // Then
        XCTAssertEqual(viewModel.unfilteredPosts.count, 2)
        XCTAssertEqual(viewModel.posts.count, 2)
        XCTAssertEqual(viewModel.unfilteredPosts.first?.isUnread, true)
        XCTAssertEqual(viewModel.unfilteredPosts.last?.isUnread, false)
        XCTAssertEqual(viewModel.posts.first?.isUnread, true)
        XCTAssertEqual(viewModel.posts.last?.isUnread, false)
        wait(for: [updatePostsExpectation], timeout: 1.0)
    }

    func testRefresh() {
        // Given
        viewModel.isRefreshingData = false
        let refreshExpectation = expectation(description: "refreshExpectation")
        postProvider?.refreshHandler = {
            refreshExpectation.fulfill()
        }
        // When
        viewModel.refresh()
        // Then
        XCTAssertEqual(viewModel.isRefreshingData, true)
        wait(for: [refreshExpectation], timeout: 1.0)
    }

    func testPostPublisherBinding() {
        // Given
        var post1 = Post()
        var post2 = Post()
        post1.identifier = "IDENTIFIER1"
        post2.identifier = "IDENTIFIER2"
        post1.isDismissed = false
        post2.isDismissed = true
        viewModel.isInitialLoading = true
        viewModel.unfilteredPosts = []
        viewModel.posts = []
        let reloadPublisherExpectation = expectation(description: "reloadPublisherExpectation")
        viewModel
            .reloadPublisher
            .sink { _ in
                reloadPublisherExpectation.fulfill()
            }
            .store(in: &disposeBag)
        // When
        postProvider?.postPublisher.send([post1, post2])
        // Then
        wait(for: [reloadPublisherExpectation], timeout: 1.0)
        XCTAssertEqual(viewModel.isInitialLoading, false)
        XCTAssertEqual(viewModel.unfilteredPosts.count, 2)
        XCTAssertEqual(viewModel.posts.count, 1)
    }

    func testNetworkActivityPublisherBindingShowMiddleLoading() {
        // Given
        viewModel.isInitialLoading = true
        viewModel.isRefreshingData = true
        let loadingStateExpectation = expectation(description: "loadingStateExpectation")
        viewModel
            .loadingStatePublisher
            .sink { state in
                XCTAssertEqual(state, .showMiddleLoading)
                loadingStateExpectation.fulfill()
            }
            .store(in: &disposeBag)
        // When
        postProvider?.networkActivityPublisher.send(true)
        // Then
        wait(for: [loadingStateExpectation], timeout: 1.0)
        XCTAssertEqual(viewModel.isInitialLoading, false)
        XCTAssertEqual(viewModel.isRefreshingData, false)
    }

    func testNetworkActivityPublisherBindingShowTopLoading() {
        // Given
        viewModel.isInitialLoading = false
        viewModel.isRefreshingData = true
        let loadingStateExpectation = expectation(description: "loadingStateExpectation")
        viewModel
            .loadingStatePublisher
            .sink { state in
                XCTAssertEqual(state, .showTopLoading)
                loadingStateExpectation.fulfill()
            }
            .store(in: &disposeBag)
        // When
        postProvider?.networkActivityPublisher.send(true)
        // Then
        wait(for: [loadingStateExpectation], timeout: 1.0)
        XCTAssertEqual(viewModel.isInitialLoading, false)
        XCTAssertEqual(viewModel.isRefreshingData, false)
    }

    func testNetworkActivityPublisherBindingShowBottomLoading() {
        // Given
        viewModel.isInitialLoading = false
        viewModel.isRefreshingData = false
        let loadingStateExpectation = expectation(description: "loadingStateExpectation")
        viewModel
            .loadingStatePublisher
            .sink { state in
                XCTAssertEqual(state, .showBottomLoading)
                loadingStateExpectation.fulfill()
            }
            .store(in: &disposeBag)
        // When
        postProvider?.networkActivityPublisher.send(true)
        // Then
        wait(for: [loadingStateExpectation], timeout: 1.0)
        XCTAssertEqual(viewModel.isInitialLoading, false)
        XCTAssertEqual(viewModel.isRefreshingData, false)
    }

    func testNetworkActivityPublisherBindingHideLoading() {
        // Given
        viewModel.isInitialLoading = true
        viewModel.isRefreshingData = true
        let loadingStateExpectation = expectation(description: "loadingStateExpectation")
        viewModel
            .loadingStatePublisher
            .sink { state in
                XCTAssertEqual(state, .hideLoading)
                loadingStateExpectation.fulfill()
            }
            .store(in: &disposeBag)
        // When
        postProvider?.networkActivityPublisher.send(false)
        // Then
        wait(for: [loadingStateExpectation], timeout: 1.0)
        XCTAssertEqual(viewModel.isInitialLoading, false)
        XCTAssertEqual(viewModel.isRefreshingData, false)
    }
}
