//
//  PersonFetchParameter.swift
//  ClientKit
//
//  Created by RUI WANG on 11/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public struct PersonFetchParameter: EntityFetchRequestable {
    public typealias ResultClass = Person
    
    public let id: String
    public var parameters: [String : Any] {
        return ["id": id]
    }
}
