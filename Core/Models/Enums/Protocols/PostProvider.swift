//
//  PostProvider.swift
//  Core
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Combine
import Foundation

public protocol PostProvider {
    func loadMore()
    func refresh()
    var postPublisher: PassthroughSubject<[Post], Never> { get }
    var networkActivityPublisher: PassthroughSubject<Bool, Never> { get }
    func updatePosts(posts: [Post]) -> AnyPublisher<Void, Never>
}
