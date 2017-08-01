//
//  ServerAPIURLRequestProvider.swift
//  MPOLKit
//
//  Created by Herli Halim on 7/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Alamofire
import MPOLKit
import Wrap
import Unbox

public protocol EntitySearchRequestable: Parameterisable {
    associatedtype ResultClass: Unboxable, MPOLKitEntityProtocol
}

// MARK: - Fetch details

public protocol EntityFetchRequestable: Parameterisable {
    associatedtype ResultClass: Unboxable, MPOLKitEntityProtocol
}

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
