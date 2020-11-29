//
//  UIColor+Theme.swift
//  Core
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/29/20.
//

import UIKit

public extension UIColor {
    static var mainBackgroundColor: UIColor {
        UIColor(named: "Background") ?? .clear
    }

    static var mainTextColor: UIColor {
        UIColor(named: "Text") ?? .clear
    }

    static var mainColor: UIColor {
        UIColor(named: "Main") ?? .clear
    }

    static var indicatorColor: UIColor {
        UIColor(named: "Indicator") ?? .clear
    }
}
