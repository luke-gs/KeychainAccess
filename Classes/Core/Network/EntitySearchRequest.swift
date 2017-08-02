//
//  EntitySearchRequest.swift
//  MPOLKit
//
//  Created by Herli Halim on 2/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

open class EntitySearchRequest<T: MPOLKitEntityProtocol>: EntitySearchRequestable {
    public typealias ResultClass = T
    
    open let parameters: [String: Any]
    
    public init(parameters: [String: Any]) {
        self.parameters = parameters
    }
}
