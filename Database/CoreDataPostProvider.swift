//
//  CoreDataPostProvider.swift
//  Database
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Combine
import Core
import CoreData
import Foundation

public class CoreDataPostProvider: OfflinePostProvider {
    private let context = CoreDataManager.context
    private var disposeBag = Set<AnyCancellable>()
    public lazy var postPublisher = PassthroughSubject<[Post], Never>()

    public init() {
        NotificationCenter.default
            .publisher(for: Notification.Name.NSManagedObjectContextObjectsDidChange)
            .sink { [weak self] notification in
                var objects: [NSManagedObject] = []
                if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>,
                   !insertedObjects.isEmpty {
                    insertedObjects.forEach { objects.append($0) }
                }
                if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
                   !updatedObjects.isEmpty {
                    updatedObjects.forEach { objects.append($0) }
                }
                let posts = objects
                    .compactMap { $0 as? PostEntity }
                    .map { Post(entity: $0) }
                if !posts.isEmpty {
                    self?.postPublisher.send(posts)
                }
            }
            .store(in: &disposeBag)
    }

    public func start() {
        context.perform { [weak self] in
            let fetchAllRequest: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
            let entities = (try? fetchAllRequest.execute()) ?? []
            let posts = entities.map { Post(entity: $0) }
            self?.postPublisher.send(posts)
        }
    }

    public func createPosts(posts: [Post]) -> AnyPublisher<Void, Never> {
        Future { [weak self] promise in
            self?.context.perform {
                defer { promise(.success(())) }
                guard let context = self?.context else { return }
                _ = posts.map { PostEntity(post: $0, context: context) }
            }
        }
        .eraseToAnyPublisher()
    }
}
