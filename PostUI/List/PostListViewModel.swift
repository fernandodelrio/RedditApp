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
    var reloadPublisher = PassthroughSubject<Void, Never>()
    var loadingStatePublisher = PassthroughSubject<LoadingState, Never>()
    var posts: [Post] = []

    init() {
        postProvider
            .postPublisher
            .sink { [weak self] posts in
                self?.unfilteredPosts.append(contentsOf: posts)
                self?.updatePosts()
                self?.reloadPublisher.send()
            }
            .store(in: &disposeBag)
        postProvider
            .networkActivityPublisher
            .sink { [weak self] isDoingNetworkActivity in
                guard let self = self else { return }

                if isDoingNetworkActivity && self.posts.isEmpty {
                    self.loadingStatePublisher.send(.showMiddleLoading)
                } else if isDoingNetworkActivity && self.isRefreshingData {
                    self.loadingStatePublisher.send(.showTopLoading)
                } else if isDoingNetworkActivity {
                    self.loadingStatePublisher.send(.showBottomLoading)
                } else {
                    self.loadingStatePublisher.send(.hideLoading)
                }
                self.isRefreshingData = false
            }
            .store(in: &disposeBag)
    }

    func load() {
        postProvider.loadMore()
    }

    func dismiss(index: Int) {
        let post = posts[index]
        let unfilteredIndex = unfilteredPosts.firstIndex { $0.identifier == post.identifier } ?? 0
        unfilteredPosts[unfilteredIndex].isDismissed = true
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
