//
//  PostProvider.swift
//  Core
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Combine
import Foundation

public protocol PostProvider {
    func loadMore()
    var postPublisher: PassthroughSubject<[Post], Never> { get }
}
