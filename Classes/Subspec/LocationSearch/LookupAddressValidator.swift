//
//  LookupAddressValidator.swift
//  MPOLKit
//
//  Created by KGWH78 on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public protocol LookupAddressValidator {
    
    func validate(item: LocationAdvancedItem, value: String?) -> String?
    
}
