//
//  RequestProvider.swift
//  Core
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Combine
import Foundation

/// @mockable
public protocol RequestProvider {
    func request(endpoint: Endpoint, with args: CVarArg...) -> AnyPublisher<Data, DataError>
    func request(url: URL) -> AnyPublisher<Data, DataError>
}
