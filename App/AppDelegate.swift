//
//  AppDelegate.swift
//  App
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Database
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    lazy var injector = Injector()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().tintColor = .mainTextColor
        // Injecting the app dependencies
        injector.load()
        return true
    }
}
