//
//  Injector.swift
//  App
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Cloud
import Core
import Database

class Injector {
    func load() {
        // Database
        Dependency.register(OfflinePostProvider.self) {
            CoreDataPostProvider()
        }

        // Cloud
        Dependency.register(OnlinePostProvider.self) {
            NetworkPostProvider()
        }

        Dependency.register(RequestProvider.self) {
            NetworkRequestProvider()
        }

        Dependency.register(EndpointProvider.self) {
            PlistEndpointProvider()
        }

        // Core
        Dependency.register(PostProvider.self) {
            DefaultPostProvider()
        }
    }
}
