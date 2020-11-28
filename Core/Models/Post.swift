//
//  Post.swift
//  Core
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Foundation

public struct Post {
    public var identifier = UUID()
    public var title = ""
    public var author = ""
    public var entryDate = Date()
    public var fullSizeImageURL = ""
    public var thumbnailURL = ""
    public var isUnread = false
    public var numberOfComments = 0
    public var redditUUID = ""

    public init() {
    }
}
