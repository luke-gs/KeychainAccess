//
//  LocationSearchStrategy.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

public protocol LocationSearchStrategy {
    func lookupAddressPromise(text: String) -> Promise<[LookupAddress]>?
}

public class LookupAddressLocationSearchStrategy: LocationSearchStrategy {
    public let source: EntitySource
    
    public init(source: EntitySource) {
        self.source = source
    }
    
    public func lookupAddressPromise(text: String) -> Promise<[LookupAddress]>? {
        return APIManager.shared.typeAheadSearchAddress(in: source, with: text)
    }
}
