//
//  OnlinePostProvider.swift
//  Core
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Combine
import Foundation

/// @mockable
public protocol OnlinePostProvider {
    func fetchPosts(afterPost: Post?) -> AnyPublisher<[Post], DataError>
}

