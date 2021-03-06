//
//  Dependency.swift
//  Core
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Foundation

public class Dependency {
    private static var registry: [String: Any] = [:]

    public static func register<T>(_ type: T.Type, value: @escaping () -> T) {
        let key = String(describing: type)
        registry[key] = value
    }

    public static func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        if let resolution = registry[key] as? () -> T {
            return resolution()
        } else {
            fatalError("Missing register dependency \(key)")
        }
    }

    public static func unregisterAll() {
        registry = [:]
    }
}
