//
//  PersonParser.swift
//  MPOLKit
//
//  Created by Gridstone on 20/6/17.
//

import UIKit

public class PersonParser: QueryParserType {
    
    required public init() { }
    
    public var delimiter: String = ","
    
    public var definitions: [QueryTokenDefinition] {
        
        // Constants (don't know the convention for where/how to declare constants in swift)
        let SurnameIndex = 0
        let MinimumSurnameLength = 2
        let MaximumSurnameLength = 16
        let MinimumGivenNameLength = 2
        let MaximumGivenNameLength = 20
        let MinimumMiddleNamesLength = 0
        let MaximumMiddleNamesLength = 50
        let MinimumAgeRange = 0
        let MaximumAgeRange = 150
        
        let ageGapRegex = try? NSRegularExpression(pattern: RegexPattern.ageGap.rawValue)
        let dateOfBirthRegex = try? NSRegularExpression(pattern: RegexPattern.dateOfBirth.rawValue)
        
        return [
            QueryTokenDefinition(key: "surname",
                                 required: true,
                                 typeCheck: { (token) in
                                    guard !token.isEmpty else { return false }
                                    let allowedCharacters = CharacterSet.letters.union(.whitespaces)
                                    let leftover = token.trimmingCharacters(in: allowedCharacters)
                                    return leftover.characters.count == 0
                                 },
                                 validate: { (token, index, map) in
                                    return index == SurnameIndex
                                        && token.characters.count > MinimumSurnameLength
                                        && token.characters.count < MaximumSurnameLength
                                 }),
            QueryTokenDefinition(key: "givenName",
                                 required: false,
                                 typeCheck: { (token) in
                                    guard !token.isEmpty else { return false }
                                    let allowedCharacters = CharacterSet.letters.union(.whitespaces)
                                    let leftover = token.trimmingCharacters(in: allowedCharacters)
                                    return leftover.characters.count == 0
                                 },
                                 validate: { (token, index, map) in
                                    return token.characters.count > MinimumGivenNameLength
                                        && token.characters.count < MaximumGivenNameLength
                                 }),
            QueryTokenDefinition(key: "middleNames",
                                 required: false,
                                 typeCheck: { (token) in
                                    guard !token.isEmpty else { return false }
                                    let allowedCharacters = CharacterSet.letters.union(.whitespaces)
                                    let leftover = token.trimmingCharacters(in: allowedCharacters)
                                    return leftover.characters.count == 0
                                 },
                                 validate: { (token, index, map) in
                                    let isGender: Bool = (token == "M" || token == "F" || token == "U") && map["gender"] == nil
                                    return !isGender
                                        && token.characters.count > MinimumMiddleNamesLength
                                        && token.characters.count < MaximumMiddleNamesLength
                                 }),
            QueryTokenDefinition(key: "gender",
                                 required: false,
                                 typeCheck: { (token) in
                                    return token == "M" || token == "F" || token == "U"
                                 }),
            QueryTokenDefinition(key: "dateOfBirth",
                                 required: false,
                                 typeCheck: { (token) in
                                    let token = token.replacingOccurrences(of: "-", with: "—")
                                    return dateOfBirthRegex!.numberOfMatches(in: token, range: NSRange(location: 0, length: token.characters.count)) == 1
                                 },
                                 validate: { (token, index, map) in
                                    // We already know that there is only one match for the token because typeCheck returned true by this point
                                    let token = token.replacingOccurrences(of: "-", with: "—")
                                    let match = dateOfBirthRegex!.matches(in: token, range: NSRange(location: 0, length: token.characters.count)).first!
                                    
                                    // Get date components ranges
                                    let dayRange = Range(match.rangeAt(1), in: token)!
                                    let monthRange = Range(match.rangeAt(2), in: token)!
                                    let yearRange = Range(match.rangeAt(3), in: token)!
                                    
                                    // Get date components
                                    let day = Int(token.substring(with: dayRange)) ?? 1
                                    let month = Int(token.substring(with: monthRange)) ?? 1
                                    let year = Int(token.substring(with: yearRange))!
                                    
                                    guard self.validate(day: day, month: month, year: year) else { return false }
                                    
                                    let components = DateComponents(year: year, month: month, day: day)
                                    guard let date = Calendar.current.date(from: components) else { return false }
                                    
                                    // Should there be a minimum age for DOB search?
                                    return date < Date()
                                 }),
            QueryTokenDefinition(key: "ageGap",
                                 required: false,
                                 typeCheck: { (token) in
                                    return ageGapRegex!.numberOfMatches(in: token, range: NSRange(location: 0, length: token.characters.count)) == 1
                                 },
                                 validate: { (token, index, map) in
                                    // We already know that there is only one match for the token because typeCheck returned true by this point
                                    let match = ageGapRegex!.matches(in: token, range: NSRange(location: 0, length: token.characters.count)).first!
                                    
                                    // Get ranges of lower and upper age
                                    let lowerRange = Range(match.rangeAt(1), in: token)!
                                    let upperRange = Range(match.rangeAt(2), in: token)!
                                    
                                    // Get lower and upper age
                                    let lower = Int(token.substring(with: lowerRange))!
                                    let upper = Int(token.substring(with: upperRange))!
                                    
                                    // Check conditions of age gap
                                    return lower > MinimumAgeRange  && lower < MaximumAgeRange
                                        && upper > MinimumAgeRange && upper < MaximumAgeRange
                                        && lower < upper
                                 })
        ]
    }
    
    func validate(day: Int, month: Int, year: Int) -> Bool {
        
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
            return false
        }
    }
}

fileprivate enum RegexPattern: String {
    case ageGap = "^(\\d+)-(\\d+)$"
    case dateOfBirth = "^([\\d]{1,2}|–)\\/([\\d]{1,2}|(?<=–\\/)–)\\/(\\d{4})$"
}
