//
//  OrganisationSearchParameter.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import Wrap

public class OrganisationSearchParameters: EntitySearchRequest<Organisation> {

    public init(name: String? = nil, abn: String? = nil, acn: String? = nil, suburb: String? = nil, nameTypeKey: String? = nil) {
        let parameterisable = SearchParameters(name: name, abn: abn, acn: acn, suburb: suburb, nameTypeKey: nameTypeKey)
        
        super.init(parameters: parameterisable.parameters)
    }
    
    private struct SearchParameters: Parameterisable {
        
        public let name: String?
        public let suburb: String?
        public let abn: String?
        public let acn: String?
        public let nameTypeKey: String?
        
        public init(name: String? = nil, abn: String? = nil, acn: String? = nil, suburb: String? = nil, nameTypeKey: String? = nil) {
            self.name = name
            self.abn = abn
            self.acn = acn
            self.suburb = suburb
            self.nameTypeKey = nameTypeKey
        }
        
        public var parameters: [String: Any] {
            return try! wrap(self)
        }
    }

}
