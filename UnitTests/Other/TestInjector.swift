//
//  TestInjector.swift
//  UnitTests
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Foundation
@testable import Cloud
@testable import Core
@testable import Database

class TestInjector {
    func reset() {
        Dependency.unregisterAll()
    }

    func load() {
        // Database
        Dependency.register(OfflinePostProvider.self) {
            OfflinePostProviderMock(postPublisher: .init())
        }

        // Cloud
        Dependency.register(ImageCacheProvider.self) {
            ImageCacheProviderMock()
        }

        Dependency.register(OnlinePostProvider.self) {
            OnlinePostProviderMock()
        }

        Dependency.register(RequestProvider.self) {
            RequestProviderMock()
        }

        Dependency.register(EndpointProvider.self) {
            EndpointProviderMock()
        }

        // Core
        Dependency.register(PostProvider.self) {
            PostProviderMock(postPublisher: .init(), networkActivityPublisher: .init())
        }
    }
}
