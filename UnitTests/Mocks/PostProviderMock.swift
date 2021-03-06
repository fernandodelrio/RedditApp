///
/// @Generated by Mockolo
///

import Combine
import Core
import Foundation

public class PostProviderMock: PostProvider {
    public init() { }
    public init(postPublisher: PassthroughSubject<[Post], Never>, networkActivityPublisher: PassthroughSubject<Bool, Never>) {
        self._postPublisher = postPublisher
        self._networkActivityPublisher = networkActivityPublisher
    }

    public private(set) var loadMoreCallCount = 0
    public var loadMoreHandler: (() -> ())?
    public func loadMore()  {
        loadMoreCallCount += 1
        if let loadMoreHandler = loadMoreHandler {
            loadMoreHandler()
        }
    }

    public private(set) var refreshCallCount = 0
    public var refreshHandler: (() -> ())?
    public func refresh()  {
        refreshCallCount += 1
        if let refreshHandler = refreshHandler {
            refreshHandler()
        }
    }

    public private(set) var postPublisherSetCallCount = 0
    private var _postPublisher: PassthroughSubject<[Post], Never>!  { didSet { postPublisherSetCallCount += 1 } }
    public var postPublisher: PassthroughSubject<[Post], Never> {
        get { return _postPublisher }
        set { _postPublisher = newValue }
    }

    public private(set) var networkActivityPublisherSetCallCount = 0
    private var _networkActivityPublisher: PassthroughSubject<Bool, Never>!  { didSet { networkActivityPublisherSetCallCount += 1 } }
    public var networkActivityPublisher: PassthroughSubject<Bool, Never> {
        get { return _networkActivityPublisher }
        set { _networkActivityPublisher = newValue }
    }

    public private(set) var updatePostsCallCount = 0
    public var updatePostsHandler: (([Post]) -> (AnyPublisher<Void, Never>))?
    public func updatePosts(posts: [Post]) -> AnyPublisher<Void, Never> {
        updatePostsCallCount += 1
        if let updatePostsHandler = updatePostsHandler {
            return updatePostsHandler(posts)
        }
        fatalError("updatePostsHandler returns can't have a default value thus its handler must be set")
    }
}
