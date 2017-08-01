//
//  APIManagerConfigurable.swift
//  MPOLKit
//
//  Created by Herli Halim on 7/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Alamofire
import Unbox

// MARK: API Configuration
public protocol APIManagerConfigurable {
    associatedtype Source: EntitySource
    var url: URLConvertible { get }
}

public struct APIManagerDefaultConfiguration<S: EntitySource>: APIManagerConfigurable {
    public typealias Source = S
    public let url: URLConvertible
    
    public init(url: URLConvertible) {
        self.url = url
    }
}
