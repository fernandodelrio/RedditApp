//
//  Post.swift
//  Core
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Foundation

public struct Post: Decodable {
    private enum CodingKeys: String, CodingKey {
        case title
        case author
        case entryDate = "created_utc"
        case fullSizeImageURL = "url"
        case thumbnailURL = "thumbnail"
        case numberOfComments = "num_comments"
        case redditUUID = "name"
    }
    public var identifier: UUID
    public var title: String
    public var author: String
    public var entryDate: Date
    public var fullSizeImageURL: String?
    public var thumbnailURL: String?
    public var isUnread: Bool
    public var numberOfComments: Int
    public var redditUUID: String

    public init() {
        identifier = UUID()
        title = ""
        author = ""
        entryDate = Date()
        isUnread = false
        numberOfComments = 0
        redditUUID = ""
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        author = try values.decode(String.self, forKey: .title)
        let timestamp = try values.decode(Int.self, forKey: .entryDate)
        entryDate = Date(timeIntervalSince1970: Double(timestamp))
        fullSizeImageURL = try values.decode(String?.self, forKey: .fullSizeImageURL)
        thumbnailURL = try values.decode(String?.self, forKey: .thumbnailURL)
        numberOfComments = try values.decode(Int.self, forKey: .numberOfComments)
        redditUUID = try values.decode(String.self, forKey: .redditUUID)
        identifier = UUID()
        isUnread = false
    }
}
