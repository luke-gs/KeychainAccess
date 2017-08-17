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
    
    public init(licenceNumber: String) {
        let parameterisable = SearchParameters(licenceNumber: licenceNumber)
        
        super.init(parameters: parameterisable.parameters)
    }
    
    private struct SearchParameters: Parameterisable {
        public let licenceNumber: String
        
        public init(licenceNumber: String) {
            self.licenceNumber = licenceNumber
        }
        
        public var parameters: [String: Any] {
            return try! wrap(self)
        }
    }
    
}
