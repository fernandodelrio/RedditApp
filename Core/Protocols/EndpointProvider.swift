//
//  EndpointProvider.swift
//  Core
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Foundation

public protocol EndpointProvider {
    func url(for endpoint: Endpoint, with args: [CVarArg]) -> URL?
}
