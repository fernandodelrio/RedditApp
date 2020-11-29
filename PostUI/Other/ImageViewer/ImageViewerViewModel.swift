//
//  ImageViewerViewModel.swift
//  PostUI
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/29/20.
//

import Combine
import Foundation

class ImageViewerViewModel {
    var imageURL = ""
    var urlPublisher = PassthroughSubject<String, Never>()

    func load() {
        urlPublisher.send(imageURL)
    }
}
