//
//  EntityDetailsFetchRequest.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import PromiseKit

public struct EntityFetchRequest<T: MPOLKitEntityProtocol>: EntityFetchRequestable {
    
    public typealias ResultClass = T
    
    public let id: String
    
    public var parameters: [String: Any] {
        return ["id": id]
    }
}

public class EntityDetailsFetchRequest<T: MPOLKitEntity> {
    public let request: EntityFetchRequest<T>
    
    public let source: EntitySource
    
    public init(source: EntitySource, request: EntityFetchRequest<T>) {
        self.source = source
        self.request = request
    }
    
    public func fetch() -> Promise<T> {
        return fetchPromise().then { result in
            return result
        }
    }
    
    public func fetchPromise() -> Promise<T> {
        MPLRequiresConcreteImplementation()
    }

}
