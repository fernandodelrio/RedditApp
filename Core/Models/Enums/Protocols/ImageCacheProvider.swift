//
//  ImageCacheProvider.swift
//  Core
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import UIKit

public protocol ImageCacheProvider {
    func save(_ image: UIImage, for url: URL)
    func retrieve(_ url: URL) -> UIImage?
}
