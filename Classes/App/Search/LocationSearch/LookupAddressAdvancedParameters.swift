//
//  LookupAddressAdvancedParameters.swift
//  MPOLKit
//
//  Created by KGWH78 on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Wrap


public struct LookupAddressAdvanceParameters: Parameterisable {
    
    public var flatType: String?
    
    public var flatNumber: String?
    
    public var streetNumberStart: String?
    
    public var streetNumberEnd: String?
    
    public var streetName: String?
    
    public var streetType: String?
    
    public var suburb: String?
    
    public var state: String?
    
    public var postalCode: String?
    
    public var country: String?
 
    public init() { }
    
    public var parameters: [String: Any] {
        return try! wrap(self)
    }
}

