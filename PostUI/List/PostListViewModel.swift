//
//  PostListViewModel.swift
//  PostUI
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Combine
import Core
import Foundation

class PostListViewModel {
    enum LoadingState {
        case showMiddleLoading
        case showTopLoading
        case showBottomLoading
        case hideLoading
    }
    private lazy var postProvider = Dependency.resolve(PostProvider.self)
    private var disposeBag = Set<AnyCancellable>()
    private var unfilteredPosts: [Post] = []
    var isRefreshingData = false
    var isInitialLoading = true
    var reloadPublisher = PassthroughSubject<Void, Never>()
    var loadingStatePublisher = PassthroughSubject<LoadingState, Never>()
    var posts: [Post] = []

    init() {
        postProvider
            .postPublisher
            .sink { [weak self] posts in
                self?.isInitialLoading = false
                self?.unfilteredPosts.append(contentsOf: posts)
                self?.updatePosts()
                self?.reloadPublisher.send()
            }
            .store(in: &disposeBag)
        postProvider
            .networkActivityPublisher
            .sink { [weak self] isDoingNetworkActivity in
                guard let self = self else { return }
                if isDoingNetworkActivity && self.isInitialLoading {
                    self.loadingStatePublisher.send(.showMiddleLoading)
                } else if isDoingNetworkActivity && self.isRefreshingData {
                    self.loadingStatePublisher.send(.showTopLoading)
                } else if isDoingNetworkActivity {
                    self.loadingStatePublisher.send(.showBottomLoading)
                } else {
                    self.loadingStatePublisher.send(.hideLoading)
                }
                self.isInitialLoading = false
                self.isRefreshingData = false
            }
            .store(in: &disposeBag)
    }

    func load() {
        postProvider.loadMore()
    }

    func dismiss(identifier: String) {
        guard let post = posts.first(where: { $0.identifier == identifier}) else {
            return
        }
        let unfilteredIndex = unfilteredPosts.firstIndex { $0.identifier == post.identifier } ?? 0
        unfilteredPosts[unfilteredIndex].isDismissed = true
        updatePosts()
        postProvider
            .updatePosts(posts: [post])
            .sink { _ in }
            .store(in: &disposeBag)
    }

    func dismissAll() {
        (0..<unfilteredPosts.count)
            .forEach { unfilteredPosts[$0].isDismissed = true }
        updatePosts()
        postProvider
            .updatePosts(posts: unfilteredPosts)
            .sink { _ in }
            .store(in: &disposeBag)
    }

    func select(index: Int) {
        let post = posts[index]
        let unfilteredIndex = unfilteredPosts.firstIndex { $0.identifier == post.identifier } ?? 0
        unfilteredPosts[unfilteredIndex].isUnread = false
        updatePosts()
        postProvider
            .updatePosts(posts: [post])
            .sink { _ in }
            .store(in: &disposeBag)
    }

    func refresh() {
        isRefreshingData = true
        postProvider.refresh()
    }

    private func updatePosts() {
        posts = unfilteredPosts.filter { !$0.isDismissed }
    }
}
