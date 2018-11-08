//
//  PersonParser.swift
//  MPOLKit
//
//  Created by Gridstone on 20/6/17.
//

import PublicSafetyKit

public class OfficerParserDefinition: QueryParserDefinition {

    public init() { }

    // MARK: - Query Parser Type

    static let componentsSeparatorSet =  CharacterSet(charactersIn: ", ")

    // expected officer search tokens [employeeNumber, familyName, givenName, middleNames]
    public func tokensFrom(query: String) -> [String] {

        let tokens: [String]
        // check for employee number
        if query.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
            let components = query.components(separatedBy: OfficerParserDefinition.componentsSeparatorSet)
            var results = [String]()
            components.forEach { component in
                if component.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
                    results.append(component)
                }
            }
            tokens = results

        // else seperate into ["lastName", "firstName", "middle names"]
        } else {
            var names: [String] = query.components(separatedBy: OfficerParserDefinition.componentsSeparatorSet).filter({ !$0.isEmpty })

            // if we have more then 3 names store the extra names in 3rd index as middle names and then remove the extra array elements
            if names.count > 3 {
                var middleName = names[2]
                for extraMiddleName in names.suffix(from: 3) {
                    middleName = [middleName, extraMiddleName].joined(separator: " ")
                }
                names[2] = middleName

                while names.count > 3 {
                    names.removeLast()
                }
            }
            // insert an empty string for employeeNumber
            names.insert(OfficerSearchParameters.nilCharacter, at: 0)
            tokens = names
        }

        return tokens.filter({ !$0.isEmpty })
    }

    public var tokenDefinitions: [QueryTokenDefinition] {
        return [
            OfficerParserDefinition.employeeNumberDefinition,
            OfficerParserDefinition.surnameDefinition,
            OfficerParserDefinition.givenNameDefinition,
            OfficerParserDefinition.middleNameDefinition
        ]
    }

    private var localizedKeyTitles: [String: String] {
        return [
            OfficerParserDefinition.EmployeeNumberKey: NSLocalizedString("Employee Number", comment: "") as String,
            OfficerParserDefinition.SurnameKey: NSLocalizedString("Surname", comment: "") as String,
            OfficerParserDefinition.GivenNameKey: NSLocalizedString("Given Name", comment: "") as String,
            OfficerParserDefinition.MiddleNameKey: NSLocalizedString("Middle Name", comment: "") as String
        ]
    }

    // MARK: - Public Static Constants

    public static let EmployeeNumberKey = "employeeNumber"
    public static let SurnameKey        = "surname"
    public static let GivenNameKey      = "givenName"
    public static let MiddleNameKey     = "middleName"

    private static let employeeNumberDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: OfficerParserDefinition.EmployeeNumberKey,
                             required: false,
                             typeCheck: employeeNumberTypeCheck,
                             validate: nil)
    }()

    private static let surnameDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: OfficerParserDefinition.SurnameKey,
                             required: false,
                             typeCheck: nameTypeCheck,
                             validate: nil)
    }()

    private static let givenNameDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: OfficerParserDefinition.GivenNameKey,
                             required: false,
                             typeCheck: nameTypeCheck,
                             validate: nil)
    }()

    private static let middleNameDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: OfficerParserDefinition.MiddleNameKey,
                             required: false,
                             typeCheck: nameTypeCheck,
                             validate: nil)
    }()

    private static let nameTypeCheck: (_ string: String) -> Bool = { (token) in
        guard !token.isEmpty else { return false }
        let allowedCharacters = CharacterSet.letters.union(.whitespaces).union(CharacterSet(charactersIn: "’'-"))
        let leftover = token.trimmingCharacters(in: allowedCharacters)
        return leftover.count == 0
    }

    private static let employeeNumberTypeCheck: (_ string: String) -> Bool = { (token) in
        guard !token.isEmpty else { return false }
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: OfficerSearchParameters.nilCharacter))
        let leftover = token.trimmingCharacters(in: allowedCharacters)
        return leftover.count == 0
    }
}
