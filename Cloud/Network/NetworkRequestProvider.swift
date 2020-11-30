//
//  NetworkRequestProvider.swift
//  Cloud
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Combine
import Core
import Foundation

public class NetworkRequestProvider: RequestProvider {
    private lazy var endpointProvider = Dependency.resolve(EndpointProvider.self)

    public init() {
    }

    // Request data from a specific endpoint
    public func request(endpoint: Endpoint, with args: CVarArg...) -> AnyPublisher<Data, DataError> {
        guard let url = endpointProvider.url(for: endpoint, with: args) else {
            return Fail(error: DataError.failedToRetrieveData).eraseToAnyPublisher()
        }
        return request(url: url)
    }

    // Request a specific URL. Used for images, for instance
    public func request(url: URL) -> AnyPublisher<Data, DataError> {
        let request = URLRequest(url: url)
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .retry(3)
            .map { $0.data }
            .mapError { _ in DataError.failedToRetrieveData }
            .eraseToAnyPublisher()
    }
}
