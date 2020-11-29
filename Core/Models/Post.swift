//
//  Post.swift
//  Core
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Foundation

public struct Post: Decodable {
    private enum CodingKeys: String, CodingKey {
        case identifier = "name"
        case title
        case author
        case entryDate = "created_utc"
        case fullSizeImageURL = "url"
        case thumbnailURL = "thumbnail"
        case numberOfComments = "num_comments"
    }
    public var identifier: String
    public var title: String
    public var author: String
    public var entryDate: Date
    public var fullSizeImageURL: String?
    public var thumbnailURL: String?
    public var isUnread: Bool
    public var numberOfComments: Int
    public var isDismissed: Bool
    public var order: Int
    public var relativeEntryDateText: String {
        formatter.localizedString(for: entryDate, relativeTo: Date())
    }
    private var formatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    public init() {
        identifier = ""
        title = ""
        author = ""
        entryDate = Date()
        isUnread = true
        isDismissed = false
        numberOfComments = 0
        order = 0
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try values.decode(String.self, forKey: .identifier)
        title = try values.decode(String.self, forKey: .title)
        author = try values.decode(String.self, forKey: .author)
        let timestamp = try values.decode(Int.self, forKey: .entryDate)
        entryDate = Date(timeIntervalSince1970: Double(timestamp))
        fullSizeImageURL = try values.decode(String?.self, forKey: .fullSizeImageURL)
        thumbnailURL = try values.decode(String?.self, forKey: .thumbnailURL)
        thumbnailURL = thumbnailURL == "default" ? nil : thumbnailURL
        fullSizeImageURL = fullSizeImageURL == "default" ? nil : fullSizeImageURL
        numberOfComments = try values.decode(Int.self, forKey: .numberOfComments)
        isUnread = true
        isDismissed = false
        order = 0
    }
}
