//
//  PersonParser.swift
//  MPOLKit
//
//  Created by Gridstone on 20/6/17.
//

import MPOLKit

public enum PersonParserError: LocalizedError {
    case surnameIsNotFirst(surname: String)
    case surnameExceedsMaxLength(surname: String, maxLength: Int)
    case givenNameExceedsMaxLength(givenName: String, maxLength: Int)
    case middleNameExistsWithoutGivenName(foundName: String)
    case nameMatchesGenderType(gender: String)
    case middleNamesExceedsMaxLength(middleNames: String, maxLength: Int)
    case ageGapWrongOrder(ageGap: String)
    case dobInvalidValues(dob: String)
    case dobDateOutOfBounds(dob: String)
    
    public var errorDescription: String? {
        var message = ""
        
        switch self {
        case PersonParserError.surnameIsNotFirst(let surname):
            message = "Potential Surname '\(surname)' found. Surname must be first. Refer to search help."
        case PersonParserError.surnameExceedsMaxLength(let surname, let maxLength):
            message = "Surname '\(surname)' exceeds maximum length of \(maxLength) characters."
        case PersonParserError.givenNameExceedsMaxLength(let givenName, let maxLength):
            message = "Given name '\(givenName)' exceeds maximum length of \(maxLength) characters."
        case PersonParserError.middleNameExistsWithoutGivenName(let middleName):
            message = "Middle name '\(middleName)' exists without a given name."
        case PersonParserError.middleNamesExceedsMaxLength(let middleName, let maxLength):
            message = "Middle name '\(middleName)' exceeds maximum length of \(maxLength) characters."
        case PersonParserError.ageGapWrongOrder(let ageGap):
            message = "Age gap '\(ageGap)' in wrong order."
        case PersonParserError.nameMatchesGenderType(let gender):
            message = "Gender '\(gender)' is invalid."
        case PersonParserError.dobInvalidValues(let dob):
            message = "'\(dob)' is not a recognised DOB. Please ensure date is valid."
        case PersonParserError.dobDateOutOfBounds(let dob):
            message = "'\(dob)' must be a past date."
        }

        return message
    }
}

public class PersonParserDefinition: QueryParserDefinition {
    
    public init() { }
    
    
    // MARK: - Query Parser Type
    
    static let componentsSeparatorSet =  CharacterSet(charactersIn: ", ")
    
    public func tokensFrom(query: String) -> [String] {

        let tokens: [String]
        if let range = query.range(of: ",") {
            let surname = String(query[..<range.lowerBound])
            var results = [surname]
            let remaining = String(query[range.upperBound...])
            results.append(contentsOf: remaining.components(separatedBy: PersonParserDefinition.componentsSeparatorSet))            
            tokens = results
        } else {
            tokens = query.components(separatedBy: PersonParserDefinition.componentsSeparatorSet)
        }

        return tokens.filter({ !$0.isEmpty })
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
    
    private var localizedKeyTitles: [String : String] {
        return [
            PersonParserDefinition.SurnameKey:      NSLocalizedString("Surname", comment: "") as String,
            PersonParserDefinition.GivenNameKey:    NSLocalizedString("Given Name", comment: "") as String,
            PersonParserDefinition.MiddleNamesKey:  NSLocalizedString("Middle Names", comment: "") as String,
            PersonParserDefinition.GenderKey:       NSLocalizedString("Gender", comment: "") as String,
            PersonParserDefinition.DateOfBirthKey:  NSLocalizedString("Date Of Birth", comment: "") as String,
            PersonParserDefinition.AgeGapKey:       NSLocalizedString("Age Gap", comment: "") as String
        ]
    }
    
    
    // MARK: - Public Static Constants
    
    public static let SurnameKey        = "surname"
    public static let GivenNameKey      = "givenName"
    public static let MiddleNamesKey    = "middleNames"
    public static let GenderKey         = "gender"
    public static let DateOfBirthKey    = "dateOfBirth"
    public static let AgeGapKey         = "ageGap"
    
    private static let surnameDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: PersonParserDefinition.SurnameKey,
                             required: true,
                             typeCheck: nameTypeCheck,
                             validate: { (token, index, map) in
                                if index != SurnameIndex {
                                    throw PersonParserError.surnameIsNotFirst(surname: token)
                                }
                                if token.count > MaximumSurnameLength {
                                    throw PersonParserError.surnameExceedsMaxLength(surname: token, maxLength: PersonParserDefinition.MaximumSurnameLength)
                                }
        })
    }()
    
    private static let givenNameDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: PersonParserDefinition.GivenNameKey,
                             required: false,
                             typeCheck: nameTypeCheck,
                             validate: { (token, index, map) in
                                if token.count > MaximumGivenNameLength {
                                    throw PersonParserError.givenNameExceedsMaxLength(givenName: token, maxLength: PersonParserDefinition.MaximumGivenNameLength)
                                }
        })
    }()
    
    private static let middleNamesDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: PersonParserDefinition.MiddleNamesKey,
                             required: false,
                             typeCheck: nameTypeCheck,
                             validate: { (token, index, map) in
                                if PersonParserDefinition.genderTypeCheck(token) && map["gender"] == nil { throw PersonParserError.nameMatchesGenderType(gender: token) }
                                if map[GivenNameKey] == nil { throw PersonParserError.middleNameExistsWithoutGivenName(foundName: token) }
                                if token.count > MaximumMiddleNamesLength {
                                    throw PersonParserError.middleNamesExceedsMaxLength(middleNames: token, maxLength: PersonParserDefinition.MaximumMiddleNamesLength)
                                }
        })
    }()
    
    private static let genderDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: PersonParserDefinition.GenderKey,
                             required: false,
                             typeCheck: genderTypeCheck)
    }()
    
    private static let dobDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: PersonParserDefinition.DateOfBirthKey,
                             required: false,
                             typeCheck: { (token) in
                                let token = token.replacingOccurrences(of: "-", with: "—")
                                return dateOfBirthRegex.numberOfMatches(in: token, range: NSRange(location: 0, length: token.count)) == 1
        },
                             validate: { (token, index, map) in
                                // We already know that there is only one match for the token because typeCheck returned true by this point
                                let token = token.replacingOccurrences(of: "-", with: "—")
                                let match = dateOfBirthRegex.matches(in: token, range: NSRange(location: 0, length: token.count)).first!
                                
                                // Get date components ranges
                                let dayRange = match.range(at: 1)
                                let monthRange = match.range(at: 2)
                                let yearRange = match.range(at: 3)
                                
                                // Get date components
                                let day = Int((token as NSString).substring(with: dayRange)) ?? 1
                                let month = Int((token as NSString).substring(with: monthRange)) ?? 1
                                let year = Int((token as NSString).substring(with: yearRange))!
                                
                                guard validateDate(day: day, month: month, year: year) else { throw PersonParserError.dobInvalidValues(dob: token) }
                                
                                let components = DateComponents(year: year, month: month, day: day)
                                let date = calendar.date(from: components)!
                                
                                // Should there be a minimum age for DOB search?
                                if date > Date() { throw PersonParserError.dobDateOutOfBounds(dob: token) }
        })
    }()
    
    private static let ageGapDefinition: QueryTokenDefinition = {
        QueryTokenDefinition(key: PersonParserDefinition.AgeGapKey,
                             required: false,
                             typeCheck: { (token) in
                                return ageGapRegex.numberOfMatches(in: token, range: NSRange(location: 0, length: token.count)) == 1
        },
                             validate: { (token, index, map) in
                                // We already know that there is only one match for the token because typeCheck returned true by this point
                                let match = ageGapRegex.matches(in: token, range: NSRange(location: 0, length: token.count)).first!
                                
                                // Age range could be xx-yy or just xx.
                                // 3 capture groups in the regex. Value in 1 & 3 is the interesting bit.
                                
                                // Get ranges of lower and upper age
                                let lowerRange = match.range(at: 1)
                                let upperRange = match.range(at: 3)
                                
                                if upperRange.location != NSNotFound {
                                    // Get lower and upper age
                                    let lower = Int((token as NSString).substring(with: lowerRange))!
                                    let upper = Int((token as NSString).substring(with: upperRange))!
                                    
                                    if lower > upper {
                                        throw PersonParserError.ageGapWrongOrder(ageGap: token)
                                    }
                                }
        })
    }()
    
    private static let MaximumSurnameLength = 20
    private static let MaximumGivenNameLength = 14
    private static let MaximumMiddleNamesLength = 14
    
    // MARK: - Private Static Constants

    private static let SurnameIndex = 0
    
    private static let ageGapRegex = try! NSRegularExpression(pattern: RegexPattern.ageGap.rawValue)
    private static let dateOfBirthRegex = try! NSRegularExpression(pattern: RegexPattern.dateOfBirth.rawValue)
    
    
    private static let nameTypeCheck: (_ string: String) -> Bool = { (token) in
        guard !token.isEmpty else { return false }
        let allowedCharacters = CharacterSet.letters.union(.whitespaces).union(CharacterSet(charactersIn: "’'-"))
        let leftover = token.trimmingCharacters(in: allowedCharacters)
        return leftover.count == 0
    }
    
    
    private static let genderTypeCheck: (_ string: String) -> Bool = { (token) in
        let checkedToken = token.uppercased()
        return checkedToken == "M" || checkedToken == "F" || checkedToken == "U"
    }
    
    
    // MARK: - Helper Methods
    
    private static let calendar: Calendar = Calendar(identifier: .gregorian)
        
    private static func validateDate(day: Int, month: Int, year: Int) -> Bool {
        
        let components = DateComponents(year: year, month: month, day: day)
        guard let resultDate = calendar.date(from: components) else {
            return false
        }
        
        let checkedComponents = calendar.dateComponents([.year, .month, .day], from: resultDate)
        return checkedComponents.year == year && checkedComponents.month == month && checkedComponents.day == day
    }
}


fileprivate enum RegexPattern: String {
    case ageGap = "^([0-9]+)(-([0-9]+))?$"
    case dateOfBirth = "^([\\d]{1,2}|–)\\/([\\d]{1,2}|(?<=–\\/)–)\\/(\\d{4})$"
}
