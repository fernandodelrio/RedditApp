//
//  NetworkPostProvider.swift
//  Cloud
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Combine
import Core
import Foundation

public class NetworkPostProvider: OnlinePostProvider {
    private lazy var requestProvider = Dependency.resolve(RequestProvider.self)
    public init() {}

    public func fetchPosts(afterPost: Post?) -> AnyPublisher<[Post], DataError> {
        let requestPublisher: AnyPublisher<Data, DataError>
        if let afterPost = afterPost {
            requestPublisher = requestProvider.request(
                endpoint: .retrieveTopPostsAfterSpecificPost,
                with: afterPost.identifier
            )
        } else {
            requestPublisher = requestProvider.request(
                endpoint: .retrieveTopPosts
            )
        }
        return requestPublisher
            .decode(type: PostResult.self, decoder: JSONDecoder())
            .map { $0.data.children.map { $0.post } }
            .mapError { _ in DataError.failedToRetrieveData }
            .eraseToAnyPublisher()
    }
}
