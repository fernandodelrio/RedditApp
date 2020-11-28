//
//  Post+Mapping.swift
//  Database
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Core
import Foundation

extension Post {
    init(entity: PostEntity) {
        self.init()
        identifier = entity.identifier ?? UUID()
        title = entity.title ?? ""
        author = entity.author ?? ""
        entryDate = entity.entryDate ?? Date()
        fullSizeImageURL = entity.fullSizeImageURL ?? ""
        thumbnailURL = entity.thumbnailURL ?? ""
        isUnread = entity.isUnread
        numberOfComments = Int(entity.numberOfComments)
        redditUUID = entity.redditUUID ?? ""
    }
}
