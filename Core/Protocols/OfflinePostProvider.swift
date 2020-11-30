//
//  OfflinePostProvider.swift
//  Core
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Combine
import Foundation

/// @mockable
public protocol OfflinePostProvider {
    var postPublisher: PassthroughSubject<[Post], Never> { get }
    func start()
    func createPosts(posts: [Post], isRecent: Bool) -> AnyPublisher<Void, Never>
    func updatePosts(posts: [Post]) -> AnyPublisher<Void, Never>
}
