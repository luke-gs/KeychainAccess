//
//  PersonParser.swift
//  MPOLKit
//
//  Created by Gridstone on 20/6/17.
//

import MPOLKit

public class OfficerParserDefinition: QueryParserDefinition {

    public init() { }

    // MARK: - Query Parser Type

    static let componentsSeparatorSet =  CharacterSet(charactersIn: ", ")

    public func tokensFrom(query: String) -> [String] {

        let tokens: [String]
        if let range = query.range(of: ",") {
            let surname = String(query[..<range.lowerBound])
            var results = [surname]
            let remaining = String(query[range.upperBound...])
            results.append(contentsOf: remaining.components(separatedBy: OfficerParserDefinition.componentsSeparatorSet))
            tokens = results
        } else {
            tokens = query.components(separatedBy: OfficerParserDefinition.componentsSeparatorSet)
        }

        return tokens.filter({ !$0.isEmpty })
    }

    public var tokenDefinitions: [QueryTokenDefinition] {
        return [
            OfficerParserDefinition.surnameDefinition,
            OfficerParserDefinition.givenNameDefinition
        ]
    }

    private var localizedKeyTitles: [String : String] {
        return [
            OfficerParserDefinition.SurnameKey:      NSLocalizedString("Surname", comment: "") as String,
            OfficerParserDefinition.GivenNameKey:    NSLocalizedString("Given Name", comment: "") as String
        ]
    }


    // MARK: - Public Static Constants

    public static let SurnameKey        = "surname"
    public static let GivenNameKey      = "givenName"

    private static let surnameDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: OfficerParserDefinition.SurnameKey,
                             required: true,
                             typeCheck: nameTypeCheck,
                             validate: nil)
    }()

    private static let givenNameDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: OfficerParserDefinition.GivenNameKey,
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
}

