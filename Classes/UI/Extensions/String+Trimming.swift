//
//  String+Trimming.swift
//  MPOLKit
//
//  Created by Kyle May on 5/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

extension String {
    
    /// Removes any non-numberic or `+` characters from a phone number string
    public func trimmingPhoneNumber() -> String {
        let phoneNumberComponents = CharacterSet(charactersIn: "01234567890+")
        return components(separatedBy: phoneNumberComponents.inverted).joined()
    }
    
}
