//
//  PersonSearchParameters.swift
//  ClientKit
//
//  Created Herli Halim on 4/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import Wrap

public class PersonSearchParameters: EntitySearchRequest<Person> {

    // Expected DOB format is dd/MM/yyyy as `String`, output is in dd-MM-yyyy
    // where dd and MM are optional.
    public init(familyName: String, givenName: String? = nil, middleNames: String? = nil, gender: String? = nil, dateOfBirth: String? = nil, age: String? = nil) {
        let parameterisable = SearchParameters(familyName: familyName,
                                               givenName: givenName,
                                               middleNames: middleNames,
                                               gender: gender,
                                               dateOfBirth: PersonSearchParameters.formattedDateOfBirthParameter(from: dateOfBirth),
                                               age: age)
        
        super.init(parameters: parameterisable.parameters)
    }

    private struct SearchParameters: Parameterisable {
        
        public let familyName: String
        public let givenName: String?
        public let middleNames: String?
        public let gender: String?
        public let dateOfBirth: String?
        public let age: String?
        
        public init(familyName: String, givenName: String? = nil, middleNames: String? = nil, gender: String? = nil, dateOfBirth: String? = nil, age: String? = nil) {
            self.familyName  = familyName
            self.givenName   = givenName
            self.middleNames = middleNames
            self.gender      = gender
            self.dateOfBirth = dateOfBirth
            self.age = age
        }
        
        public var parameters: [String: Any] {
            return try! wrap(self)
        }
    }

    private static func formattedDateOfBirthParameter(from dateString: String?) -> String? {

        guard let date = dateString else {
            return nil
        }

        let dateComponents = PersonSearchDateParser.dateComponents(from: date)

        var components: [String] = []

        if let day = dateComponents.day {
            components.append(day)
        }

        if let month = dateComponents.month {
            components.append(month)
        }

        components.append(dateComponents.year)

        return components.joined(separator: "-")
    }
}
