//
//  PostEntity+Mapping.swift
//  Database
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Core
import CoreData
import Foundation

extension PostEntity {
    convenience init(post: Post, context: NSManagedObjectContext) {
        self.init(context: context)
        identifier = post.identifier
        title = post.title
        author = post.author
        entryDate = post.entryDate
        fullSizeImageURL = post.fullSizeImageURL
        thumbnailURL = post.thumbnailURL
        isUnread = post.isUnread
        numberOfComments = Int32(post.numberOfComments)
        redditUUID = post.redditUUID
    }
}
