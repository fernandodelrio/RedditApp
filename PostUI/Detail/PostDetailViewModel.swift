//
//  PostDetailViewModel.swift
//  PostUI
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/29/20.
//

import Combine
import Core
import Foundation

class PostDetailsViewModel: ObservableObject {
    var post: Post?
    @Published var author = ""
    @Published var imageURL = ""
    @Published var title = ""

    func load() {
        if let post = post {
            author = post.author
            title = post.title
            if let url = post.thumbnailURL {
                imageURL = url
            }
        }
    }
}
