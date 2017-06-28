//
//  PersonParser.swift
//  MPOLKit
//
//  Created by Gridstone on 20/6/17.
//

import UIKit

public enum PersonParserError: Error {
    case surnameIsNotFirst(surname: String)
    case surnameLengthOutOfBounds(surname: String)
    case givenNameLengthOutOfBounds(givenName: String)
    case nameMatchesGenderType(gender: String)
    case middleNamesLengthOutOfBounds(middleNames: String)
    case ageGapOutOfRange(ageGap: String)
    case ageGapWrongOrder(ageGap: String)
    case dobInvalidValues(dob: String)
    case dobDateOutOfBounds(dob: String)
}

open class PersonParserDefinition: QueryParserDefinition {
    
    public init() { }
    
    
    // MARK: - Query Parser Type
    
    public func tokensFrom(query: String) -> [String] {
        if query.contains(",") { return query.components(separatedBy: ",") }
        return query.components(separatedBy: " ")
    }
    
    public var tokenDefinitions: [QueryTokenDefinition] {
        return [
            PersonParserDefinition.surnameDefinition,
            PersonParserDefinition.givenNameDefinition,
            PersonParserDefinition.middleNamesDefinition,
            PersonParserDefinition.genderDefinition,
            PersonParserDefinition.dobDefinition,
            PersonParserDefinition.ageGapDefinition
        ]
    }
    
    
    // MARK: - Public Static Constants
    
    public static let surnameDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: "surname",
                             required: true,
                             typeCheck: nameTypeCheck,
                             validate: { (token, index, map) in
                                if index != SurnameIndex {
                                    throw PersonParserError.surnameIsNotFirst(surname: token)
                                }
                                if token.characters.count < MinimumSurnameLength || token.characters.count > MaximumSurnameLength {
                                    throw PersonParserError.surnameLengthOutOfBounds(surname: token)
                                }
        })
    }()
    
    public static let givenNameDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: "givenName",
                             required: false,
                             typeCheck: nameTypeCheck,
                             validate: { (token, index, map) in
                                if token.characters.count < MinimumGivenNameLength || token.characters.count > MaximumGivenNameLength {
                                    throw PersonParserError.givenNameLengthOutOfBounds(givenName: token)
                                }
        })
    }()
    
    public static let middleNamesDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: "middleNames",
                             required: false,
                             typeCheck: nameTypeCheck,
                             validate: { (token, index, map) in
                                if PersonParserDefinition.genderTypeCheck(token) && map["gender"] == nil { throw PersonParserError.nameMatchesGenderType(gender: token) }
                                if token.characters.count < MinimumMiddleNamesLength || token.characters.count > MaximumMiddleNamesLength {
                                    throw PersonParserError.middleNamesLengthOutOfBounds(middleNames: token)
                                }
        })
    }()
    
    public static let genderDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: "gender",
                             required: false,
                             typeCheck: genderTypeCheck)
    }()
    
    public static let dobDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: "dateOfBirth",
                             required: false,
                             typeCheck: { (token) in
                                let token = token.replacingOccurrences(of: "-", with: "—")
                                return dateOfBirthRegex.numberOfMatches(in: token, range: NSRange(location: 0, length: token.characters.count)) == 1
        },
                             validate: { (token, index, map) in
                                // We already know that there is only one match for the token because typeCheck returned true by this point
                                let token = token.replacingOccurrences(of: "-", with: "—")
                                let match = dateOfBirthRegex.matches(in: token, range: NSRange(location: 0, length: token.characters.count)).first!
                                
                                // Get date components ranges
                                let dayRange = match.rangeAt(1)
                                let monthRange = match.rangeAt(2)
                                let yearRange = match.rangeAt(3)
                                
                                // Get date components
                                let day = Int((token as NSString).substring(with: dayRange)) ?? 1
                                let month = Int((token as NSString).substring(with: monthRange)) ?? 1
                                let year = Int((token as NSString).substring(with: yearRange))!
                                
                                guard validateDate(day: day, month: month, year: year) else { throw PersonParserError.dobInvalidValues(dob: token) }
                                
                                let components = DateComponents(year: year, month: month, day: day)
                                let date = Calendar.current.date(from: components)!
                                
                                // Should there be a minimum age for DOB search?
                                if date > Date() { throw PersonParserError.dobDateOutOfBounds(dob: token) }
        })
    }()
    
    public static let ageGapDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: "ageGap",
                             required: false,
                             typeCheck: { (token) in
                                return ageGapRegex.numberOfMatches(in: token, range: NSRange(location: 0, length: token.characters.count)) == 1
        },
                             validate: { (token, index, map) in
                                // We already know that there is only one match for the token because typeCheck returned true by this point
                                let match = ageGapRegex.matches(in: token, range: NSRange(location: 0, length: token.characters.count)).first!
                                
                                // Get ranges of lower and upper age
                                let lowerRange = match.rangeAt(1)
                                let upperRange = match.rangeAt(2)
                                
                                // Get lower and upper age
                                let lower = Int((token as NSString).substring(with: lowerRange))!
                                let upper = Int((token as NSString).substring(with: upperRange))!
                                
                                if lower < MinimumAgeRange || lower > MaximumAgeRange || upper < MinimumAgeRange || upper > MaximumAgeRange {
                                    throw PersonParserError.ageGapOutOfRange(ageGap: token)
                                }
                                
                                if lower > upper {
                                    throw PersonParserError.ageGapWrongOrder(ageGap: token)
                                }
        })
    }()
    
    
    // MARK: - Private Static Constants

    private static let SurnameIndex = 0
    private static let MinimumSurnameLength = 2
    private static let MaximumSurnameLength = 16
    private static let MinimumGivenNameLength = 2
    private static let MaximumGivenNameLength = 20
    private static let MinimumMiddleNamesLength = 0
    private static let MaximumMiddleNamesLength = 50
    private static let MinimumAgeRange = 0
    private static let MaximumAgeRange = 150
    
    
    private static let ageGapRegex = try! NSRegularExpression(pattern: RegexPattern.ageGap.rawValue)
    private static let dateOfBirthRegex = try! NSRegularExpression(pattern: RegexPattern.dateOfBirth.rawValue)
    
    
    private static let nameTypeCheck: (_ string: String) -> Bool = { (token) in
        guard !token.isEmpty else { return false }
        let allowedCharacters = CharacterSet.letters.union(.whitespaces)
        let leftover = token.trimmingCharacters(in: allowedCharacters)
        return leftover.characters.count == 0
    }
    
    
    private static let genderTypeCheck: (_ string: String) -> Bool = { (token) in
        return token == "M" || token == "F" || token == "U"
    }
    
    
    // MARK: - Helper Methods
    
    private static func validateDate(day: Int, month: Int, year: Int) -> Bool {
        // validate year
        let maxYear = Calendar.current.component(.year, from: Date())
        let minYear = maxYear - 150
        guard year > minYear && year <= maxYear else { return false }
        
        let isLeapYear = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
        
        // validate day & month
        guard day > 0 else { return false }
        switch month {
        case 2:
            if isLeapYear {
                return day <= 29
            } else {
                return day <= 28
            }
        case 4, 6, 9, 11:
            return day <= 30
        case 1, 3, 5, 7, 8, 10, 12:
            return day <= 31
        default:
            // if month is not 1 - 12, default case will execute
            return false
        }
    }
}


fileprivate enum RegexPattern: String {
    case ageGap = "^(\\d+)-(\\d+)$"
    case dateOfBirth = "^([\\d]{1,2}|–)\\/([\\d]{1,2}|(?<=–\\/)–)\\/(\\d{4})$"
}
