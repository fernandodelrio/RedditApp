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
                let posts = objects
                    .compactMap { $0 as? PostEntity }
                    .map { Post(entity: $0) }
                    .sorted { $0.order < $1.order }
                if !posts.isEmpty {
                    self?.postPublisher.send(posts)
                }
            }
            .store(in: &disposeBag)
    }

    public func start() {
        context.perform { [weak self] in
            let fetchAllRequest: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
            fetchAllRequest.sortDescriptors = [.init(key: "order", ascending: true)]
            let entities = (try? fetchAllRequest.execute()) ?? []
            let posts = entities
                .map { Post(entity: $0) }
            self?.postPublisher.send(posts)
        }
    }

    public func createPosts(posts: [Post], isRecent: Bool) -> AnyPublisher<Void, Never> {
        Future { [weak self] promise in
            self?.context.perform {
                defer { promise(.success(())) }
                let entities = self?.fetchExistingPosts(posts: posts) ?? []
                let existingIdentifiers = entities.compactMap { $0.identifier }
                let newPosts = posts
                    .filter { !existingIdentifiers.contains($0.identifier) }
                let newPostsWithOrder = self?.definePostsOrder(posts: newPosts, isRecent: isRecent) ?? []
                newPostsWithOrder.forEach { print("### \($0.title) \($0.order)") }
                guard let context = self?.context else { return }
                _ = newPostsWithOrder.map { PostEntity(post: $0, context: context) }
            }
        }
        .eraseToAnyPublisher()
    }

    public func updatePosts(posts: [Post]) -> AnyPublisher<Void, Never> {
        Future { [weak self] promise in
            self?.context.perform {
                defer { promise(.success(())) }
                let entities = self?.fetchExistingPosts(posts: posts) ?? []
                entities.forEach { entity in
                    if let post = posts.first(where: { $0.identifier == entity.identifier }) {
                        entity.update(with: post)
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func fetchExistingPosts(posts: [Post]) -> [PostEntity] {
        let identifiers = posts.map { $0.identifier }
        let fetchRequest: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier in %@", identifiers)
        return (try? fetchRequest.execute()) ?? []
    }

    private func fetchMinimumOrder() -> Int? {
        let fetchRequest: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        fetchRequest.sortDescriptors = [.init(key: "order", ascending: true)]
        fetchRequest.fetchLimit = 1
        let entities = try? fetchRequest.execute()
        return (entities?.first?.order).map { Int($0) }
    }

    private func fetchMaximumOrder() -> Int {
        let fetchRequest: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        fetchRequest.sortDescriptors = [.init(key: "order", ascending: false)]
        fetchRequest.fetchLimit = 1
        let entities = try? fetchRequest.execute()
        return (entities?.first?.order).map { Int($0) } ?? 0
    }

    private func definePostsOrder(posts: [Post], isRecent: Bool) -> [Post] {
        var posts = posts
        var order: Int
        if isRecent {
            if let minimumOrder = fetchMinimumOrder() {
                order = minimumOrder - posts.count
            } else {
                order = 0
            }
        } else {
            order = fetchMaximumOrder() + 1
        }
        (0..<posts.count)
            .forEach { index in
                posts[index].order = order
                order += 1
            }
        return posts
    }
}
