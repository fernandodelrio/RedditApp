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
    @Published var image = ""
    @Published var title = ""

    func load() {
        image = post?.thumbnailURL ?? ""
        title = post?.title ?? ""
    }
}
