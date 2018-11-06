//
//  OfficerSearchParameters.swift
//  MPOL
//
//  Created by QHMW64 on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import Wrap

public class OfficerSearchParameters: EntitySearchRequest<Officer> {

    public static let nilCharacter = "*"

    public init(familyName: String? = nil, givenName: String? = nil, middleNames: String? = nil, employeeNumber: String? = nil) {
        let parameterisable = SearchParameters(familyName: familyName, givenName: givenName, middleNames: middleNames, employeeNumber: employeeNumber)

        super.init(parameters: parameterisable.parameters)
    }

    private struct SearchParameters: Parameterisable {

        public let familyName: String?
        public let givenName: String?
        public let middleNames: String?
        public let employeeNumber: String?

        public init(familyName: String?, givenName: String? = nil, middleNames: String? = nil, employeeNumber: String? = nil) {
            self.familyName = familyName
            self.givenName = givenName
            self.middleNames = middleNames
            self.employeeNumber = employeeNumber == OfficerSearchParameters.nilCharacter ? nil : employeeNumber
        }

        public var parameters: [String: Any] {
            return try! wrap(self)
        }
    }
}
