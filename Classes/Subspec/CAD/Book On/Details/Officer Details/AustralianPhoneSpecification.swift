//
//  AustralianPhoneSpecification.swift
//  MPOLKit
//
//  Created by Kyle May on 1/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class AustralianPhoneSpecification: Specification {
    public func isSatisfiedBy(_ candidate: Any?) -> Bool {
        if let number = candidate as? String {
            return isValidAustralianPhoneNumber(number)
        }
        
        return false
    }
    
    /// Checks if the string is a valid Australian phone number
    func isValidAustralianPhoneNumber(_ number: String) -> Bool {
        let phoneRegex = "^\\+?61[0-9]{9}|^(0[0-9])?[0-9]{8}"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)

        return phoneTest.evaluate(with: number.replacingOccurrences(of: " ", with: ""))
    }
}
