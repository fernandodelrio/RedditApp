//
//  DefaultPostProvider.swift
//  Core
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Combine
import Foundation

public class DefaultPostProvider: PostProvider {
    public lazy var postPublisher = PassthroughSubject<[Post], Never>()
    private lazy var offlineProvider = Dependency.resolve(OfflinePostProvider.self)
    private lazy var onlineProvider = Dependency.resolve(OnlinePostProvider.self)
    private var lastPost: Post?
    private var offlineProviderStarted = false
    private var disposeBag = Set<AnyCancellable>()

    public init() {
        offlineProvider
            .postPublisher
            .sink { [weak self] posts in
                if posts.isEmpty {
                    self?.fetchOnlinePosts()
                } else {
                    self?.lastPost = posts.last
                }
            }
            .store(in: &disposeBag)
    }

    public func loadMore() {
        if !offlineProviderStarted {
            offlineProvider.start()
            offlineProviderStarted = true
        } else {
            fetchOnlinePosts()
        }
    }

    private func fetchOnlinePosts() {
        onlineProvider
            .fetchPosts(afterPost: lastPost)
            .retry(3)
            .flatMap { [weak self] posts in
                self?.offlineProvider.createPosts(posts: posts) ?? Just(()).eraseToAnyPublisher()
            }
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &disposeBag)
    }
}
