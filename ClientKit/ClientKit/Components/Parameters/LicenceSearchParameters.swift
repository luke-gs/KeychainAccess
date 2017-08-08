//
//  LicenceSearchParameters.swift
//  ClientKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import Wrap


public class LicenceSearchParameters: EntitySearchRequest<Person> {
    
    public init(licence: String) {
        let parameterisable = SearchParameters(licence: licence)
        
        super.init(parameters: parameterisable.parameters)
    }
    
    private struct SearchParameters: Parameterisable {
        public let licence: String
        
        public init(licence: String) {
            self.licence = licence
        }
        
        public var parameters: [String: Any] {
            return try! wrap(self)
        }
    }
    
}
