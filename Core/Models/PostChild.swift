//
//  PostChild.swift
//  Core
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Foundation

public struct PostChild: Decodable {
    private enum CodingKeys: String, CodingKey {
        case post = "data"
    }
    public var post: Post
}
