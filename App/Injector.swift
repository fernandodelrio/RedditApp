//
//  Injector.swift
//  App
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Core
import Database

class Injector {
    func load() {
        Dependency.register(OfflinePostProvider.self) {
            CoreDataPostProvider()
        }

        Dependency.register(PostProvider.self) {
            DefaultPostProvider()
        }
    }
}
