//
//  PostListViewModel.swift
//  PostUI
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Combine
import Core
import Foundation

class PostListViewModel: ObservableObject {
    private lazy var postProvider = Dependency.resolve(PostProvider.self)
    private var disposeBag = Set<AnyCancellable>()
    @Published var posts: [Post] = []

    init() {
        postProvider
            .postPublisher
            .sink { [weak self] posts in
                self?.posts = posts
            }
            .store(in: &disposeBag)
    }

    func load() {
        postProvider.loadMore()
    }

    func dismiss(index: Int) {
        
    }

}
