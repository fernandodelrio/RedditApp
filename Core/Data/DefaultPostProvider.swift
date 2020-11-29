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
    public lazy var networkActivityPublisher = PassthroughSubject<Bool, Never>()
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
                    self?.postPublisher.send(posts)
                }
            }
            .store(in: &disposeBag)
    }

    public func refresh() {
        lastPost = nil
        fetchOnlinePosts()
    }

    public func loadMore() {
        if !offlineProviderStarted {
            offlineProvider.start()
            offlineProviderStarted = true
        } else {
            fetchOnlinePosts()
        }
    }

    public func updatePosts(posts: [Post]) -> AnyPublisher<Void, Never> {
        offlineProvider.updatePosts(posts: posts)
    }

    private func fetchOnlinePosts() {
        networkActivityPublisher.send(true)
        let createPostAsRecent = lastPost == nil
        onlineProvider
            .fetchPosts(afterPost: lastPost)
            .flatMap { [weak self] posts in
                self?.offlineProvider.createPosts(posts: posts, isRecent: createPostAsRecent) ?? Just(()).eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.networkActivityPublisher.send(false)
                },
                receiveValue: { _ in }
            )
            .store(in: &disposeBag)
    }
}
