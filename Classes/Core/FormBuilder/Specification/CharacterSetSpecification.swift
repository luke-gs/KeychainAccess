// MIT license. Copyright (c) 2017 SwiftyFORM. All rights reserved.
import Foundation

/// Check if a string has no illegal characters.
public class CharacterSetSpecification: Specification {
    private let characterSet: CharacterSet

    public init(characterSet: CharacterSet) {
        self.characterSet = characterSet
    }

    public static func charactersInString(_ charactersInString: String) -> CharacterSetSpecification {
        let cs = CharacterSet(charactersIn: charactersInString)
        return CharacterSetSpecification(characterSet: cs)
    }

    /// Check if all characters are contained in the characterset.
    ///
    /// - parameter candidate: The object to be checked.
    ///
    /// - returns: `true` if the candidate object is a string and all its characters are legal, `false` otherwise.
    public func isSatisfiedBy(_ candidate: Any?) -> Bool {
        guard let fullString = candidate as? String else { return false }
        for character: Character in fullString.characters {
            let range: Range<String.Index>? =
                String(character).rangeOfCharacter(from: characterSet)
            if range == nil {
                return false // one or more characters does not satify the characterSet
            }
            if range!.isEmpty {
                return false // one or more characters does not satify the characterSet
            }
        }
        return true // the whole string satisfies the characterSet
    }
}

extension CharacterSetSpecification {
    public static var alphanumerics: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.alphanumerics)
    }
    public static var capitalizedLetters: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.capitalizedLetters)
    }
    public static var controlCharacters: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.controlCharacters)
    }
    public static var decimalDigits: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.decimalDigits)
    }
    public static var decomposables: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.decomposables)
    }
    public static var illegalCharacters: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.illegalCharacters)
    }
    public static var letters: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.letters)
    }
    public static var lowercaseLetters: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.lowercaseLetters)
    }
    public static var newlines: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.newlines)
    }
    public static var nonBaseCharacters: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.nonBaseCharacters)
    }
    public static var punctuationCharacters: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.punctuationCharacters)
    }
    public static var symbols: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.symbols)
    }
    public static var uppercaseLetters: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.uppercaseLetters)
    }
    public static var urlFragmentAllowed: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.urlFragmentAllowed)
    }
    public static var urlHostAllowed: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.urlHostAllowed)
    }
    public static var urlPasswordAllowed: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.urlPasswordAllowed)
    }
    public static var urlPathAllowed: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.urlPathAllowed)
    }
    public static var urlQueryAllowed: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.urlQueryAllowed)
    }
    public static var urlUserAllowed: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.urlUserAllowed)
    }
    public static var whitespaces: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.whitespaces)
    }
    public static var whitespacesAndNewlines: CharacterSetSpecification {
        return CharacterSetSpecification(characterSet: CharacterSet.whitespacesAndNewlines)
    }
}
