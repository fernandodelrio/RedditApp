//
//  CoreDataManager.swift
//  Database
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Combine
import CoreData
import UIKit

class CoreDataManager {
    private static var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle(for: CoreDataManager.self)
        guard let url = bundle.url(forResource: "RedditApp", withExtension:"momd"),
            let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Couldn't retrieve core data stack")
        }

        let container = NSPersistentContainer(name: "RedditApp", managedObjectModel: model)
        // Saving the context only when necessary
        let didEnterBackground = NotificationCenter.default.publisher(
            for: UIApplication.didEnterBackgroundNotification
        )
        let willTerminate = NotificationCenter.default.publisher(
            for: UIApplication.willTerminateNotification
        )
        Publishers
            .Merge(didEnterBackground, willTerminate)
            .sink { _ in saveContext() }
            .store(in: &disposeBag)
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    private static var disposeBag = Set<AnyCancellable>()
    static var context = persistentContainer.newBackgroundContext()

    @objc private static func saveContext() {
        context.perform {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
}
