//
//  OfficerSearchParameters.swift
//  ClientKit
//
//  Created by QHMW64 on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import Wrap

public class OfficerSearchParameters: EntitySearchRequest<Officer> {

    public init(familyName: String, givenName: String? = nil, middleNames: String? = nil, region: String? = nil, employeeNumber: String? = nil) {
        let parameterisable = SearchParameters(familyName: familyName, givenName: givenName, middleNames: middleNames, region: region, employeeNumber: employeeNumber)

        super.init(parameters: parameterisable.parameters)
    }

    private struct SearchParameters: Parameterisable {

        public let region: String?
        public let familyName: String
        public let givenName: String?
        public let middleNames: String?
        public let employeeNumber: String?

        public init(familyName: String, givenName: String? = nil, middleNames: String? = nil, region: String? = nil, employeeNumber: String? = nil) {
            self.familyName  = familyName
            self.givenName   = givenName
            self.middleNames = middleNames
            self.region      = region
            self.employeeNumber = employeeNumber
        }

        public var parameters: [String: Any] {
            return try! wrap(self)
        }
    }
}
