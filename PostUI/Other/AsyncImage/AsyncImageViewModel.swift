//
//  AsyncImageViewModel.swift
//  PostUI
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Combine
import Core
import UIKit

class AsyncImageViewModel {
    private lazy var imageCacheProvider = Dependency.resolve(ImageCacheProvider.self)
    private lazy var requestProvider = Dependency.resolve(RequestProvider.self)
    private var disposeBag = Set<AnyCancellable>()

    func loadImage(_ url: URL?) -> AnyPublisher<UIImage?, Never> {
        guard let url = url else {
            return Just(nil).eraseToAnyPublisher()
        }
        if let cached = imageCacheProvider.retrieve(url) {
            return Just(cached).eraseToAnyPublisher()
        } else {
            return requestProvider
                .request(url: url)
                .map { UIImage(data: $0) }
                .catch { _ in Just(nil).eraseToAnyPublisher() }
                .eraseToAnyPublisher()
        }
    }
}
