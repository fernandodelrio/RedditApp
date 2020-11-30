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
    lazy var imageCacheProvider = Dependency.resolve(ImageCacheProvider.self)
    lazy var requestProvider = Dependency.resolve(RequestProvider.self)
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
                .map { [weak self] data -> UIImage? in
                    let image = UIImage(data: data)
                    if let cacheImage = image {
                        self?.imageCacheProvider.save(cacheImage, for: url)
                    }
                    return image
                }
                .catch { _ in Just(nil).eraseToAnyPublisher() }
                .eraseToAnyPublisher()
        }
    }
}
